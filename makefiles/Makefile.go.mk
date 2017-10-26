.PHONY : go

go: pyalgorithms
#go: pyinit pycp pyalgorithms pygraph pylp pysat
test_go: test_go_examples
BUILT_LANGUAGES +=, go

# Clean target
clean_go:
	-$(DELREC) $(GEN_DIR)$Sgo$Salgorithms$S*
	-$(DELREC) $(GEN_DIR)$Sgo$Sconstraint_solver$S*
	-$(DELREC) $(GEN_DIR)$Sgo$Sgraph$S*
	-$(DELREC) $(GEN_DIR)$Sgo$Slinear_solver$S*
	-$(DELREC) $(GEN_DIR)$Sgo$Ssat$S*
	-$(DEL) $(GEN_DIR)$Sgo$S__init__.go
	-$(DEL) $(GEN_DIR)$Salgorithms$S*go_wrap*
	-$(DEL) $(GEN_DIR)$Sconstraint_solver$S*go_wrap*
	-$(DEL) $(GEN_DIR)$Sgraph$S*go_wrap*
	-$(DEL) $(GEN_DIR)$Slinear_solver$S*go_wrap*
	-$(DEL) $(GEN_DIR)$Ssat$S*go_wrap*
	-$(DEL) $(GEN_DIR)$Salgorithms$S*.go
	-$(DEL) $(GEN_DIR)$Sconstraint_solver$S*.go
	-$(DEL) $(GEN_DIR)$Sgraph$S*.go
	-$(DEL) $(GEN_DIR)$Slinear_solver$S*.go
	-$(DEL) $(GEN_DIR)$Ssat$S*.go
	-$(DEL) $(GEN_DIR)$Salgorithms$S*.pyc
	-$(DEL) $(GEN_DIR)$Sconstraint_solver$S*.pyc
	-$(DEL) $(GEN_DIR)$Sgraph$S*.pyc
	-$(DEL) $(GEN_DIR)$Slinear_solver$S*.pyc
	-$(DEL) $(GEN_DIR)$Ssat$S*.pyc
	-$(DEL) $(LIB_DIR)$S_wrap*.$(SWIG_LIB_SUFFIX)
	-$(DEL) $(OBJ_DIR)$Sswig$S*go_wrap.$O

# knapsack_solver
goalgorithms: $(LIB_DIR)/_knapsack_solver.$(SWIG_LIB_SUFFIX) $(GEN_DIR)/go/algorithms/knapsack_solver.go $(GEN_DIR)/go/algorithms/build.go

$(GEN_DIR)/go/algorithms/build.go: \
		$(SRC_DIR)/ortools/algorithms/go/build.go
	cp $(SRC_DIR)/ortools/algorithms/go/build.go $(GEN_DIR)/go/algorithms/build.go

$(GEN_DIR)/go/algorithms/knapsack_solver.go: \
		$(SRC_DIR)/ortools/base/base.i \
		$(SRC_DIR)/ortools/util/python/vector.i \
		$(SRC_DIR)/ortools/algorithms/go/knapsack_solver.i \
		$(SRC_DIR)/ortools/algorithms/knapsack_solver.h
	$(SWIG_BINARY) -I$(INC_DIR) -c++ -go -cgo -intgosize 64 -o $(GEN_DIR)$Sgo$Salgorithms$Sknapsack_solver_wrap.cc -module knapsack_solver $(SRC_DIR)/ortools/algorithms$Sgo$Sknapsack_solver.i

$(GEN_DIR)/go/algorithms/knapsack_solver_wrap.cc: $(GEN_DIR)/go/algorithms/knapsack_solver.go

$(OBJ_DIR)/swig/knapsack_solver_wrap.$O: $(GEN_DIR)/go/algorithms/knapsack_solver_wrap.cc $(ALGORITHMS_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) -c $(GEN_DIR)$Sgo$Salgorithms$Sknapsack_solver_wrap.cc $(OBJ_OUT)$(OBJ_DIR)$Sswig$Sknapsack_solver_wrap.$O

$(LIB_DIR)/_knapsack_solver.$(SWIG_LIB_SUFFIX): $(OBJ_DIR)/swig/knapsack_solver_wrap.$O $(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) $(LDOUT)$(LIB_DIR)$S_knapsack_solver.$(SWIG_LIB_SUFFIX) $(OBJ_DIR)$Sswig$Sknapsack_solver_wrap.$O $(OR_TOOLS_LNK) $(SYS_LNK) $(PYTHON_LNK)
ifeq "$(SYSTEM)" "win"
	copy $(LIB_DIR)\\_knapsack_solver.dll $(GEN_DIR)\\ortools\\algorithms\\_knapsack_solver.pyd
else
	cp $(LIB_DIR)/_knapsack_solver.$(SWIG_LIB_SUFFIX) $(GEN_DIR)/go/algorithms
endif

# gowrapgraph
gograph: $(LIB_DIR)/_wrapgraph.$(SWIG_LIB_SUFFIX) $(GEN_DIR)/go/graph/gowrapgraph.go

$(GEN_DIR)/go/graph/gowrapgraph.py: \
		$(SRC_DIR)/ortools/base/base.i \
		$(SRC_DIR)/ortools/util/python/vector.i \
		$(SRC_DIR)/ortools/graph/python/graph.i \
		$(SRC_DIR)/ortools/graph/min_cost_flow.h \
		$(SRC_DIR)/ortools/graph/max_flow.h \
		$(SRC_DIR)/ortools/graph/ebert_graph.h \
		$(SRC_DIR)/ortools/graph/shortestpaths.h
	$(SWIG_BINARY) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) -o $(GEN_DIR)$Sgo$Sgraph$Sgraph_thon_wrap.cc -module gowrapgraph $(SRC_DIR)/ortools/graph$Spython$Sgraph.i

$(GEN_DIR)/go/graph/graph_thon_wrap.cc: $(GEN_DIR)/go/graph/gowrapgraph.go

$(OBJ_DIR)/swig/graph_thon_wrap.$O: $(GEN_DIR)/go/graph/graph_thon_wrap.cc $(GRAPH_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) -c $(GEN_DIR)/go/graph/graph_thon_wrap.cc $(OBJ_OUT)$(OBJ_DIR)$Sswig$Sgraph_thon_wrap.$O

$(LIB_DIR)/_wrapgraph.$(SWIG_LIB_SUFFIX): $(OBJ_DIR)/swig/graph_thon_wrap.$O $(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) $(LDOUT)$(LIB_DIR)$S_wrapgraph.$(SWIG_LIB_SUFFIX) $(OBJ_DIR)$Sswig$Sgraph_thon_wrap.$O $(OR_TOOLS_LNK) $(SYS_LNK) $(PYTHON_LNK)
ifeq "$(SYSTEM)" "win"
	copy $(LIB_DIR)\\_wrapgraph.dll $(GEN_DIR)\\ortools\\graph\\_wrapgraph.pyd
else
	cp $(LIB_DIR)/_wrapgraph.$(SWIG_LIB_SUFFIX) $(GEN_DIR)/go/graph
endif

# gowrapcp

gocp: $(GEN_DIR)/go/constraint_solver/gowrapcp.py $(LIB_DIR)/_wrapcp.$(SWIG_LIB_SUFFIX)

$(GEN_DIR)/go/constraint_solver/search_limit_pb2.py: $(SRC_DIR)/ortools/constraint_solver/search_limit.proto
	$(PROTOBUF_DIR)/bin/protoc --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) $(SRC_DIR)$Sortools$Sconstraint_solver$Ssearch_limit.proto

$(GEN_DIR)/go/constraint_solver/model_pb2.py: $(SRC_DIR)/ortools/constraint_solver/model.proto $(GEN_DIR)/go/constraint_solver/search_limit_pb2.go
	$(PROTOBUF_DIR)/bin/protoc --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) $(SRC_DIR)$Sortools$Sconstraint_solver$Smodel.proto

$(GEN_DIR)/go/constraint_solver/assignment_pb2.py: $(SRC_DIR)/ortools/constraint_solver/assignment.proto
	$(PROTOBUF_DIR)/bin/protoc --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) $(SRC_DIR)$Sortools$Sconstraint_solver$Sassignment.proto

$(GEN_DIR)/go/constraint_solver/solver_parameters_pb2.py: $(SRC_DIR)/ortools/constraint_solver/solver_parameters.proto
	$(PROTOBUF_DIR)/bin/protoc --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) $(SRC_DIR)$Sortools$Sconstraint_solver$Ssolver_parameters.proto

$(GEN_DIR)/go/constraint_solver/routing_enums_pb2.py: $(SRC_DIR)/ortools/constraint_solver/routing_enums.proto
	$(PROTOBUF_DIR)/bin/protoc --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) $(SRC_DIR)$Sortools$Sconstraint_solver$Srouting_enums.proto

$(GEN_DIR)/go/constraint_solver/routing_parameters_pb2.py: $(SRC_DIR)/ortools/constraint_solver/routing_parameters.proto $(GEN_DIR)/go/constraint_solver/solver_parameters_pb2.py $(GEN_DIR)/go/constraint_solver/routing_enums_pb2.go
	$(PROTOBUF_DIR)/bin/protoc --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) $(SRC_DIR)$Sortools$Sconstraint_solver$Srouting_parameters.proto

$(GEN_DIR)/go/constraint_solver/gowrapcp.py: \
		$(SRC_DIR)/ortools/base/base.i \
		$(SRC_DIR)/ortools/util/python/vector.i \
		$(SRC_DIR)/ortools/constraint_solver/python/constraint_solver.i \
		$(SRC_DIR)/ortools/constraint_solver/python/routing.i \
		$(SRC_DIR)/ortools/constraint_solver/constraint_solver.h \
		$(SRC_DIR)/ortools/constraint_solver/constraint_solveri.h \
		$(GEN_DIR)/go/constraint_solver/assignment_pb2.py \
		$(GEN_DIR)/go/constraint_solver/model_pb2.py \
		$(GEN_DIR)/go/constraint_solver/routing_enums_pb2.py \
		$(GEN_DIR)/go/constraint_solver/routing_parameters_pb2.py \
		$(GEN_DIR)/go/constraint_solver/search_limit_pb2.py \
		$(GEN_DIR)/go/constraint_solver/solver_parameters_pb2.py \
		$(GEN_DIR)/go/constraint_solver/assignment.pb.h \
		$(GEN_DIR)/go/constraint_solver/model.pb.h \
		$(GEN_DIR)/go/constraint_solver/search_limit.pb.h \
		$(CP_LIB_OBJS)
	$(SWIG_BINARY) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) -o $(GEN_DIR)$Sgo$Sconstraint_solver$Sconstraint_solver_wrap.cc -module gowrapcp $(SRC_DIR)/ortools/constraint_solver$Spython$Srouting.i

# TODO(user): Support gowraprouting as well.

$(GEN_DIR)/go/constraint_solver/constraint_solver_wrap.cc: $(GEN_DIR)/go/constraint_solver/gowrapcp.go

$(OBJ_DIR)/swig/constraint_solver_wrap.$O: $(GEN_DIR)/go/constraint_solver/constraint_solver_wrap.cc $(CP_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) -c $(GEN_DIR)$Sgo$Sconstraint_solver$Sconstraint_solver_wrap.cc $(OBJ_OUT)$(OBJ_DIR)$Sswig$Sconstraint_solver_wrap.$O

$(LIB_DIR)/_wrapcp.$(SWIG_LIB_SUFFIX): \
		$(OBJ_DIR)/swig/constraint_solver_wrap.$O \
			$(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) $(LDOUT)$(LIB_DIR)$S_wrapcp.$(SWIG_LIB_SUFFIX) $(OBJ_DIR)$Sswig$Sconstraint_solver_wrap.$O $(OR_TOOLS_LNK) $(SYS_LNK) $(PYTHON_LNK)
ifeq "$(SYSTEM)" "win"
	copy $(LIB_DIR)\\_wrapcp.dll $(GEN_DIR)\\ortools\\constraint_solver\\_wrapcp.pyd
else
	cp $(LIB_DIR)/_wrapcp.$(SWIG_LIB_SUFFIX) $(GEN_DIR)/go/constraint_solver
endif

# gowraplp

golp: $(LIB_DIR)/_wraplp.$(SWIG_LIB_SUFFIX) $(GEN_DIR)/go/linear_solver/gowraplp.go

$(GEN_DIR)/go/linear_solver/linear_solver_pb2.py: $(SRC_DIR)/ortools/linear_solver/linear_solver.proto
	$(PROTOBUF_DIR)/bin/protoc --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) $(SRC_DIR)/ortools/linear_solver/linear_solver.proto

$(GEN_DIR)/go/linear_solver/gowraplp.py: \
		$(SRC_DIR)/ortools/base/base.i \
		$(SRC_DIR)/ortools/util/python/vector.i \
		$(SRC_DIR)/ortools/linear_solver/python/linear_solver.i \
		$(SRC_DIR)/ortools/linear_solver/linear_solver.h \
		$(GEN_DIR)/go/linear_solver/linear_solver.pb.h \
		$(GEN_DIR)/go/linear_solver/linear_solver_pb2.go
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) -o $(GEN_DIR)$Sgo$Slinear_solver$Slinear_solver_wrap.cc -module gowraplp $(SRC_DIR)/ortools/linear_solver$Spython$Slinear_solver.i

$(GEN_DIR)/go/linear_solver/linear_solver_wrap.cc: $(GEN_DIR)/go/linear_solver/gowraplp.go

$(OBJ_DIR)/swig/linear_solver_wrap.$O: $(GEN_DIR)/go/linear_solver/linear_solver_wrap.cc $(LP_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) -c $(GEN_DIR)$Sgo$Slinear_solver$Slinear_solver_wrap.cc $(OBJ_OUT)$(OBJ_DIR)$Sswig$Slinear_solver_wrap.$O

$(LIB_DIR)/_wraplp.$(SWIG_LIB_SUFFIX): \
		$(OBJ_DIR)/swig/linear_solver_wrap.$O \
			$(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) $(LDOUT)$(LIB_DIR)$S_wraplp.$(SWIG_LIB_SUFFIX) $(OBJ_DIR)$Sswig$Slinear_solver_wrap.$O $(OR_TOOLS_LNK) $(SYS_LNK) $(PYTHON_LNK)
ifeq "$(SYSTEM)" "win"
	copy $(LIB_DIR)\\_wraplp.dll $(GEN_DIR)\\ortools\\linear_solver\\_wraplp.pyd
else
	cp $(LIB_DIR)/_wraplp.$(SWIG_LIB_SUFFIX) $(GEN_DIR)/go/linear_solver
endif

# gowrapsat

gosat: $(LIB_DIR)/_wrapsat.$(SWIG_LIB_SUFFIX) $(GEN_DIR)/go/sat/gowrapsat.go

$(GEN_DIR)/go/sat/cp_model_pb2.py: $(SRC_DIR)/ortools/sat/cp_model.proto
	$(PROTOBUF_DIR)/bin/protoc --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) $(SRC_DIR)/ortools/sat/cp_model.proto

$(GEN_DIR)/go/sat/sat_parameters_pb2.py: $(SRC_DIR)/ortools/sat/sat_parameters.proto
	$(PROTOBUF_DIR)/bin/protoc --proto_path=$(INC_DIR) --python_out=$(GEN_DIR) $(SRC_DIR)/ortools/sat/sat_parameters.proto

$(GEN_DIR)/go/sat/gowrapsat.py: \
		$(SRC_DIR)/ortools/base/base.i \
		$(SRC_DIR)/ortools/util/python/vector.i \
		$(SRC_DIR)/ortools/sat/python/sat.i \
		$(GEN_DIR)/go/sat/cp_model_pb2.py \
		$(GEN_DIR)/go/sat/sat_parameters_pb2.py \
		$(SAT_DEPS)
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -python $(SWIG_PYTHON3_FLAG) -o $(GEN_DIR)$Sgo$Ssat$Ssat_go_wrap.cc -module gowrapsat $(SRC_DIR)/ortools/sat$Spython$Ssat.i

$(GEN_DIR)/go/sat/sat_go_wrap.cc: $(GEN_DIR)/go/sat/gowrapsat.go

$(OBJ_DIR)/swig/sat_go_wrap.$O: $(GEN_DIR)/go/sat/sat_go_wrap.cc $(SAT_DEPS)
	$(CCC) $(CFLAGS) $(PYTHON_INC) -c $(GEN_DIR)$Sgo$Ssat$Ssat_go_wrap.cc $(OBJ_OUT)$(OBJ_DIR)$Sswig$Ssat_go_wrap.$O

$(LIB_DIR)/_gowrapsat.$(SWIG_LIB_SUFFIX): \
		$(OBJ_DIR)/swig/sat_go_wrap.$O \
			$(OR_TOOLS_LIBS)
	$(DYNAMIC_LD) $(LDOUT)$(LIB_DIR)$S_gowrapsat.$(SWIG_LIB_SUFFIX) $(OBJ_DIR)$Sswig$Ssat_go_wrap.$O $(OR_TOOLS_LNK) $(SYS_LNK) $(PYTHON_LNK)
ifeq "$(SYSTEM)" "win"
	copy $(LIB_DIR)\\_gowrapsat.dll $(GEN_DIR)\\ortools\\sat\\_gowrapsat.pyd
else
	cp $(LIB_DIR)/_gowrapsat.$(SWIG_LIB_SUFFIX) $(GEN_DIR)/go/sat
endif

