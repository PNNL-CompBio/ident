import kotte_model
from parallel_ode import setup_parallel_ode
from simulate_ode import setup_serial_ode


class ModelSim(object):
    def __init__(self, rhs_fun, flux_fun, noise=0, **kwargs):
        self.rhs_fun = rhs_fun
        self.flux_fun = flux_fun
        self.noise = noise
        # kinetics
        try:
            self.kinetics = kwargs['kinetics']
        except KeyError:
            self.kinetics = 2
        # ode solver options
        try:
            self.ode_opts = kwargs['ode_opts']
        except KeyError:
            self.ode_opts = {'iter': 'Newton', 'discr': 'Adams', 'atol': 1e-10, 'rtol': 1e-10,
                             'time_points': 200, 'display_progress': True, 'verbosity': 30}
        # number of samples (applicable when noise=1)
        try:
            self.samples = kwargs['samples']
        except KeyError:
            self.sample = 1
        # simulation time horizon (for all sims)
        try:
            self.t_final = kwargs['t_final']
        except KeyError:
            self.t_final = 500
        # set wt initial value (to run all simulations)
        try:
            self.wt_y0 = kwargs['wt_y0']
        except KeyError:
            self.wt_y0 = []

    def run_initial_sim(self, parameter, **kwargs):
        try:
            wt_sim_result = self.sim_model([parameter], [kwargs['y0']])
        except KeyError:
            wt_sim_result = self.sim_model([parameter], [self.wt_y0])
        return wt_sim_result

    def sim_model(self, parameter, initial_value):
        """simulate model with defined rhs fun and given parameters, initial values and
        ode solver options (if given, else use default)"""

        # call parallel solver instance for multiple parameter/initial values
        if len(initial_value) > 1:
            sim_result = setup_parallel_ode(ode_rhs_fun=self.rhs_fun, parameters=parameter, y0=initial_value,
                                            t_final=self.t_final, ode_opts=self.ode_opts, i_value_opt=1,
                                            parameter_opt=0)
            # get flux values
        elif len(parameter) > 1:
            sim_result = setup_parallel_ode(ode_rhs_fun=self.rhs_fun, parameters=parameter, y0=initial_value,
                                            t_final=self.t_final, ode_opts=self.ode_opts, i_value_opt=0,
                                            parameter_opt=1)
            # get flux values
        else:
            # use serial solver instance to solve for multiple parameter/initial values
            import pdb; pdb.set_trace()
            sim_result = setup_serial_ode(ode_fun=self.rhs_fun, y_initial=initial_value[0], t_final=self.t_final,
                                          opts=[self.ode_opts, parameter[0]])
            import pdb; pdb.set_trace()

        # get ss values
        # set self.wt_ss

        return sim_result


if __name__ == '__main__':
    user_ode_opts = {'iter': 'Newton', 'discr': 'Adams', 'atol': 1e-10, 'rtol': 1e-10,
                     'time_points': 200, 'display_progress': True, 'verbosity': 30}
    # initial ss to begin all simulations from
    y0 = np.array([5, 1, 1])
    # default set of parameters to begin simulations with
    model_parameters = {"K1ac": np.array([.1]), "K3fdp": np.array([.1]), "L3fdp": np.array([4e6]),
                        "K3pep": np.array([.1]), "K2pep": np.array([.3]), "vemax": np.array([1.1]),
                        "Kefdp": np.array([.45]), "ne": np.array([2]), "d": np.array([.25]), "V4max": np.array([.2]),
                        "k1cat": np.array([1]), "V3max": np.array([1]), "V2max": np.array([1]), "ac": np.array([.1])}
    # create simulation object to simulate model with above parameters and initial conditions
    model_1 = ModelSim(kotte_model.kotte_ck_ode, kotte_model.kotte_ck_flux, noise=0, **{'kinetics': 2,
                                                                                        'ode_opts': user_ode_opts,
                                                                                        't_final': 200,
                                                                                        'wt_y0': y0})
    # call model.simulate to get initial (WT) steady state for all parameter sets strating from same y0
    initial_wt_result = model_1.run_initial_sim(parameter=model_parameters)

    # sim_result = model_1.sim_model(parameter=model_parameter, initial_value=y0)

    # call model.simulate to get perturbed steady state for all
    # parameter perturbation from corresponding steady states y0
    # sim_perturbation_result = model_1.sim_model

    # call model.change_parameter
