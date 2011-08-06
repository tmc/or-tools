// Copyright 2010-2011 Google
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "graph/max_flow.h"

#include "base/commandlineflags.h"
#include "base/stringprintf.h"

DEFINE_bool(max_flow_check_input, false,
            "Check that the input is consistent.");
DEFINE_bool(max_flow_check_result, false,
            "Check that the result is valid.");

namespace operations_research {

MaxFlow::MaxFlow(const StarGraph* graph,
                 NodeIndex source,
                 NodeIndex sink)
    : graph_(graph),
      node_excess_(),
      node_potential_(),
      residual_arc_capacity_(),
      first_admissible_arc_(),
      active_nodes_(),
      source_(source),
      sink_(sink) {
  const NodeIndex max_num_nodes = graph_->max_num_nodes();
  if (max_num_nodes > 0) {
    node_excess_.Reserve(StarGraph::kFirstNode, max_num_nodes - 1);
    node_excess_.Assign(0);
    node_potential_.Reserve(StarGraph::kFirstNode, max_num_nodes - 1);
    node_potential_.Assign(0);
    first_admissible_arc_.Reserve(StarGraph::kFirstNode, max_num_nodes - 1);
    first_admissible_arc_.Assign(StarGraph::kNilArc);
  }
  const ArcIndex max_num_arcs = graph_->max_num_arcs();
  if (max_num_arcs > 0) {
    residual_arc_capacity_.Reserve(-max_num_arcs, max_num_arcs - 1);
    residual_arc_capacity_.Assign(0);
  }
  DCHECK(graph_->CheckNodeValidity(source_));
  DCHECK(graph_->CheckNodeValidity(sink_));
}

bool MaxFlow::CheckInputConsistency() const {
  bool ok = true;
  for (StarGraph::ArcIterator arc_it(*graph_); arc_it.Ok(); arc_it.Next()) {
    const ArcIndex arc = arc_it.Index();
    if (residual_arc_capacity_[arc] < 0) {
      ok = false;
    }
  }
  return ok;
}

// Sets the capacity for arc.
void MaxFlow::SetArcCapacity(ArcIndex arc, FlowQuantity new_capacity) {
  DCHECK_LE(0, new_capacity);
  DCHECK(graph_->CheckArcValidity(arc));
  const FlowQuantity free_capacity = residual_arc_capacity_[arc];
  const FlowQuantity capacity_delta = new_capacity - Capacity(arc);
  VLOG(2) << "Changing capacity on arc " << arc
          << " from " << Capacity(arc) << " to " << new_capacity
          << ". Current free capacity = " << free_capacity;
  if (capacity_delta == 0) {
    return;  // Nothing to do.
  }
  status_ = NOT_SOLVED;
  if (free_capacity + capacity_delta >= 0) {
    // The above condition is true if one of the two conditions is true:
    // 1/ (capacity_delta > 0), meaning we are increasing the capacity
    // 2/ (capacity_delta < 0 && free_capacity + capacity_delta >= 0)
    //    meaning we are reducing the capacity, but that the capacity
    //    reduction is not larger than the free capacity.
    residual_arc_capacity_.Set(arc, free_capacity + capacity_delta);
    DCHECK_LE(0, residual_arc_capacity_[arc]);
    VLOG(2) << "Now: capacity = " << Capacity(arc) << " flow = " << Flow(arc);
  } else {
    // We have to reduce the flow on the arc, and update the excesses
    // accordingly.
    const FlowQuantity flow = residual_arc_capacity_[Opposite(arc)];
    const FlowQuantity flow_excess = flow - new_capacity;
    VLOG(2) << "Flow value " << flow << " exceeds new capacity "
            << new_capacity << " by " << flow_excess;
    residual_arc_capacity_.Set(arc, 0);
    residual_arc_capacity_.Set(Opposite(arc), new_capacity);
    const NodeIndex head = Head(arc);
    node_excess_.Set(head, node_excess_[head] + flow_excess);
    DCHECK_LE(0, residual_arc_capacity_[arc]);
    DCHECK_LE(0, residual_arc_capacity_[Opposite(arc)]);
    VLOG(2) << DebugString("After SetArcCapacity:", arc);
  }
}

bool MaxFlow::CheckResult() const {
  bool ok = true;
  for (StarGraph::NodeIterator node_it(*graph_); node_it.Ok(); node_it.Next()) {
    const NodeIndex node = node_it.Index();
    if (node != source_ && node != sink_) {
      if (node_excess_[node] != 0) {
        LOG(DFATAL) << "node_excess_[" << node << "] = " << node_excess_[node]
                    << " != 0";
        ok = false;
      }
    }
  }
  for (StarGraph::ArcIterator arc_it(*graph_); arc_it.Ok(); arc_it.Next()) {
    const ArcIndex arc = arc_it.Index();
    const ArcIndex opposite = Opposite(arc);
    const FlowQuantity direct_capacity = residual_arc_capacity_[arc];
    const FlowQuantity opposite_capacity = residual_arc_capacity_[opposite];
    if (direct_capacity < 0) {
      LOG(DFATAL) << "residual_arc_capacity_[" << arc << "] = "
                  << direct_capacity << " != 0";
      ok = false;
    }
    if (opposite_capacity < 0) {
      LOG(DFATAL) << "residual_arc_capacity_[" << opposite << "] = "
                  << opposite_capacity << " != 0";
      ok = false;
    }
    // The initial capacity of the direct arcs is non-negative.
    if (direct_capacity + opposite_capacity < 0) {
      LOG(DFATAL) << "initial capacity [" << arc << "] = "
                  << direct_capacity + opposite_capacity << " < 0";
      ok = false;
    }
  }
  return ok;
}

bool MaxFlow::CheckRelabelPrecondition(NodeIndex node) const {
  DCHECK(IsActive(node));
  for (StarGraph::IncidentArcIterator arc_it(*graph_, node);
       arc_it.Ok();
       arc_it.Next()) {
    const ArcIndex arc = arc_it.Index();
    DCHECK(!IsAdmissible(arc));
  }
  return true;
}

string MaxFlow::DebugString(const string& context, ArcIndex arc) const {
  const NodeIndex tail = Tail(arc);
  const NodeIndex head = Head(arc);
  return StringPrintf("%s Arc %lld, from %lld to %lld, "
                      "Capacity = %lld, Residual capacity = %lld, "
                      "Flow = residual capacity for reverse arc = %lld, "
                      "Height(tail) = %lld, Height(head) = %lld, "
                      "Excess(tail) = %lld, Excess(head) = %lld",
                      context.c_str(), arc, tail, head, Capacity(arc),
                      residual_arc_capacity_[arc], Flow(arc),
                      node_potential_[tail], node_potential_[head],
                      node_excess_[tail], node_excess_[head]);
}

bool MaxFlow::Solve() {
  status_ = NOT_SOLVED;
  if (FLAGS_max_flow_check_input && !CheckInputConsistency()) {
    status_ = BAD_INPUT;
    return false;
  }
  InitializePreflow();
  ResetFirstAdmissibleArcs();
  Refine();
  if (FLAGS_max_flow_check_result && !CheckResult()) {
    status_ = BAD_RESULT;
    return false;
  }
  total_flow_ = 0;
  for (StarGraph::OutgoingArcIterator arc_it(*graph_, source_);
       arc_it.Ok();
       arc_it.Next()) {
    const ArcIndex arc = arc_it.Index();
    total_flow_ += Flow(arc);
  }
  status_ = OPTIMAL;
  return true;
}

void MaxFlow::ResetFirstAdmissibleArcs() {
  for (StarGraph::NodeIterator node_it(*graph_); node_it.Ok(); node_it.Next()) {
    const NodeIndex node = node_it.Index();
    first_admissible_arc_.Set(node, GetFirstIncidentArc(node));
  }
}

void MaxFlow::InitializePreflow() {
  // InitializePreflow() clears the whole flow that could have been computed
  // by a previous Solve(). This is not optimal in terms of complexity.
  // TODO(user): find a way to make the re-solving incremental (not an obvious
  // task, and there has not been a lot of literature on the subject.)
  node_potential_.Assign(0);
  node_excess_.Assign(0);
  for (StarGraph::ArcIterator arc_it(*graph_); arc_it.Ok(); arc_it.Next()) {
    const ArcIndex arc = arc_it.Index();
    // Reset the residual capacities of direct arc to their initial values.
    residual_arc_capacity_.Set(arc, Capacity(arc));
    // The initial residual capacities on reverse arcs are set to 0.
    residual_arc_capacity_.Set(Opposite(arc), 0);
  }
  // The initial height of the source is equal to the number of nodes.
  node_potential_.Set(source_, graph_->num_nodes());
  for (StarGraph::OutgoingArcIterator arc_it(*graph_, source_);
       arc_it.Ok();
       arc_it.Next()) {
    const ArcIndex arc = arc_it.Index();
    const FlowQuantity arc_capacity = Capacity(arc);
    // Saturate arcs outgoing from the source. This is not really a PushFlow,
    // since the preconditions for PushFlow are not (yet) met, and we do not
    // need to update the excess at the source.
    residual_arc_capacity_.Set(arc, 0);
    residual_arc_capacity_.Set(Opposite(arc), arc_capacity);
    node_excess_.Set(Head(arc), arc_capacity);
    VLOG(2) << DebugString("InitializePreflow:", arc);
  }
}

void MaxFlow::PushFlow(FlowQuantity flow, ArcIndex arc) {
  DCHECK_GT(residual_arc_capacity_[arc], 0);
  DCHECK_GT(node_excess_[Tail(arc)], 0);
  VLOG(2) << "PushFlow: pushing " << flow << " on arc " << arc
          << " from node " << Tail(arc) << " to node " << Head(arc);
  // Reduce the residual capacity on arc by flow.
  residual_arc_capacity_.Set(arc, residual_arc_capacity_[arc] - flow);
  // Increase the residual capacity on opposite arc by flow.
  const ArcIndex opposite = Opposite(arc);
  residual_arc_capacity_.Set(opposite, residual_arc_capacity_[opposite] + flow);
  // Update the excesses at the tail and head of the arc.
  const NodeIndex tail = Tail(arc);
  node_excess_.Set(tail, node_excess_[tail] - flow);
  const NodeIndex head = Head(arc);
  node_excess_.Set(head, node_excess_[head] + flow);
  VLOG(3) << DebugString("PushFlow: ", arc);
}

void MaxFlow::InitializeActiveNodeStack() {
  DCHECK(active_nodes_.empty());
  for (StarGraph::NodeIterator node_it(*graph_); node_it.Ok(); node_it.Next()) {
    const NodeIndex node = node_it.Index();
    if (IsActive(node)) {
      active_nodes_.push(node);
      VLOG(2) << "InitializeActiveNodeStack: node " << node << " added.";
    }
  }
}

void MaxFlow::Refine() {
  InitializeActiveNodeStack();
  while (!active_nodes_.empty()) {
    const NodeIndex node = active_nodes_.top();
    active_nodes_.pop();
    if (IsActive(node)) {
      VLOG(2) << "Refine: calling Discharge for node " << node;
      Discharge(node);
    }
  }
}

void MaxFlow::Discharge(NodeIndex node) {
  DCHECK(IsActive(node));
  VLOG(2) << "Discharging node " << node << ", excess = " << node_excess_[node];
  while (IsActive(node)) {
    for (StarGraph::IncidentArcIterator arc_it(*graph_, node,
                                               first_admissible_arc_[node]);
         arc_it.Ok();
         arc_it.Next()) {
      const ArcIndex arc = arc_it.Index();
      VLOG(3) << DebugString("Discharge: considering", arc);
      if (IsAdmissible(arc)) {
        if (node_excess_[node] != 0) {
          VLOG(2) << "Discharge: calling PushFlow.";
          const NodeIndex head = Head(arc);
          const bool head_active_before_push = IsActive(head);
          const FlowQuantity delta = std::min(node_excess_[node],
                                              residual_arc_capacity_[arc]);
          PushFlow(delta, arc);
          if (IsActive(head) && !head_active_before_push) {
            active_nodes_.push(Head(arc));
          }
        }
        if (node_excess_[node] == 0) {
          first_admissible_arc_.Set(node, arc);  // arc may still be admissible.
          return;
        }
      }
    }
    Relabel(node);
  }
}

void MaxFlow::Relabel(NodeIndex node) {
  DCHECK(CheckRelabelPrecondition(node));
  CostValue min_height = node_potential_[node];
  for (StarGraph::IncidentArcIterator arc_it(*graph_, node);
       arc_it.Ok();
       arc_it.Next()) {
    const ArcIndex arc = arc_it.Index();
    DCHECK_EQ(Tail(arc), node);
    if (residual_arc_capacity_[arc] > 0) {
      // Update min_height only for arcs with available capacity.
      min_height = std::min(min_height, node_potential_[Head(arc)]);
    }
  }
  VLOG(2) << "Relabel: height(" << node << ") relabeled from "
          << node_potential_[node] << " to " << min_height + 1;
  node_potential_.Set(node, min_height + 1);
  first_admissible_arc_.Set(node, GetFirstIncidentArc(node));
}

}  // namespace operations_research

