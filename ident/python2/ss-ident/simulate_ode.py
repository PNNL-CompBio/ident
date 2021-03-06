import matplotlib.pyplot as plt
from assimulo.solvers import CVode
from assimulo.problem import Explicit_Problem


def simulate_ode(fun, y_initial, tf, opts):
    "function to run CVode solver on given problem"
    # get options
    ode_opts, ode_system_options = opts
    # iter, discretization_method, atol, rtol, time_points = ode_opts
    iter = ode_opts["iter"]
    discretization_method = ode_opts["discr"]
    atol = ode_opts["atol"]
    rtol = ode_opts["rtol"]
    time_points = ode_opts["time_points"]
    try:
        display_progress = ode_opts["display_progress"]
    except KeyError:
        display_progress = True
    try:
        verbosity = ode_opts["verbosity"]
    except KeyError:
        verbosity = 10

    # define explicit assimulo problem
    prob = Explicit_Problem(lambda t, x: fun(t, x, ode_system_options), y0=y_initial)

    # create solver instance
    solver = CVode(prob)

    # set solver options
    solver.iter, solver.discr, solver.atol, solver.rtol, solver.display_progress, solver.verbosity = \
        iter, discretization_method, atol, rtol, display_progress, verbosity

    # simulate system
    time_course, y_result = solver.simulate(tf, time_points)

    return time_course, y_result, prob, solver


def setup_serial_ode(ode_fun, y_initial, t_final, opts):
    """run ode code on single processor as a serial process"""
    time_points, y_dynamic, prob, solver = simulate_ode(ode_fun, y_initial, t_final, opts)
    sim_result = [{'time': time_points, 'y': y_dynamic}]
    return sim_result


def run_ode_sims(fun, y_initial, opts, t_final=500, args_1=False):
    """run kotte model ode using cvode from assimulo"""

    # def_par_val = np.array([.1, .1, 4e6, .1, .3, 1.1, .45, 2, .25, .2, 1, 1, 1, .1])
    time_points, y_dynamic, prob, solver = simulate_ode(fun, y_initial, t_final, opts)
    if args_1:
        plt.plot(time_points, y_dynamic, color="r")
        plt.xlabel('Time')
        plt.ylabel('Dependent Variables')
        plt.show()

    return time_points, y_dynamic, prob, solver


