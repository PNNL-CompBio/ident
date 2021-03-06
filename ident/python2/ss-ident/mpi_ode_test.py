import numpy as np
import predator_prey_model
from parallel_ode import setup_parallel_ode


def py_rhs_fun(t, y, p):
    alpha = p[0]
    beta = p[1]
    delta = p[2]
    gamma = p[3]

    flux = np.array([alpha * y[0], beta * y[0] * y[1], delta * y[0] * y[1], gamma * y[1]])
    rhs = np.array([flux[0] - flux[1], flux[2] - flux[3]])

    return rhs


def rhs_fun(t, y, p):
    """ode rhs fun for predator prey model using imported fortran code"""
    flux = predator_prey_model.all_flux(y, p)
    rhs = predator_prey_model.ode(flux)

    return rhs


if __name__ == "__main__":

    parameters = np.array([.5, .02, .4, .004])
    ode_opts = {'iter': 'Newton', 'discr': 'Adams', 'atol': 1e-10, 'rtol': 1e-10,
                'time_points': 200, 'display_progress': True, 'verbosity': 30}
    y0 = [np.array([1, .0001]), np.array([2, .0001]), np.array([3, .0001]), np.array([4, .0001]),
          np.array([5, .0001]), np.array([.0001, 1]), np.array([.0001, 2]), np.array([.0001, 3]),
          np.array([.0001, 4]), np.array([.0001, 5]), np.array([10, 1]), np.array([1, 10])]
    # import pdb; pdb.set_trace()
    sim_result = setup_parallel_ode(ode_rhs_fun=rhs_fun, parameters=parameters, y0=y0, t_final=200, ode_opts=ode_opts)