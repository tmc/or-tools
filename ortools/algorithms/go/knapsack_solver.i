// Copyright 2010-2017 Google
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

// 

%include "ortools/base/base.i"

// Include the file we want to wrap a first time.
%{
#include "ortools/algorithms/knapsack_solver.h"
%}

%include "std_vector.i"

// See the comment in
// ../../constraint_solver/csharp/constraint_solver.i about naming
// the template instantiation of std::vector<> differently.
%template(KInt64Vector) std::vector<int64>;
%template(KInt64VectorVector) std::vector<std::vector<int64> >;

%rename (UseReduction) operations_research::KnapsackSolver::use_reduction;
%rename (SetUseReduction) operations_research::KnapsackSolver::set_use_reduction;
%rename (TimeLimit) operations_research::KnapsackSolver::time_limit;
%rename (SetTimeLimit) operations_research::KnapsackSolver::set_time_limit;

%typemap(gotype) const std::vector<int64>& %{[]int64%}

%typemap(imtype) const std::vector<int64>& "uintptr"

%typemap(goin) const std::vector<int64>& {
    v := NewKInt64Vector()
    for _, i := range $1 {
        v.Add(i)
    }
    $result = v.Swigcptr()
}

%typemap(gotype) const std::vector<std::vector<int64>>& %{[][]int64%}

%typemap(imtype) const std::vector<std::vector<int64>>& "uintptr"

%typemap(goin) const std::vector<std::vector<int64>>& {
    v := NewKInt64VectorVector()
    for _, i := range $1 {
        u := NewKInt64Vector()
        for _, j := range i {
            u.Add(j)
        }
        v.Add(u)
    }
    $result = v.Swigcptr()
}

%include "ortools/algorithms/knapsack_solver.h"
