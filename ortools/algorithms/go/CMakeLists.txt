IF(BUILD_GO)
    SET_PROPERTY(SOURCE knapsack_solver.i PROPERTY CPLUSPLUS ON)
    SET_PROPERTY(SOURCE knapsack_solver.i PROPERTY SWIG_MODULE_NAME wrapknapsack_solver)

    SWIG_ADD_LIBRARY(wrapknapsack_solver TYPE MODULE LANGUAGE go SOURCES knapsack_solver.i)
    SWIG_LINK_LIBRARIES(wrapknapsack_solver ${PROJECT_NAME})

ENDIF(BUILD_GO)
