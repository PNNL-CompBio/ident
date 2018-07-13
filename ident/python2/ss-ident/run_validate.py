from run_sims import ModelSim
from names_strings import variable_name
import pandas as pd


class ValidateSim(ModelSim):
    def __init__(self, rhs_fun, flux_fun, noise=0, **kwargs):
        super(ValidateSim, self).__init__(rhs_fun, flux_fun, noise, **kwargs)
        # self.rhs_fun = rhs_fun
        # self.flux_fun = flux_fun
        # self.noise = noise

        # all parameter perturbations to be tested
        try:
            self.test_perturbations = kwargs['test_perturbations']
        except KeyError:
            self.test_perturbations = [{"wt": 0}, {"ac": 1}, {"ac": 4}, {"ac": 9}, {"ac": -.1}, {"ac": -.5},
                                       {"k1cat": .1}, {"k1cat": .5}, {"k1cat": 1}, {"k1cat": -.1}, {"k1cat": -.5},
                                       {"V3max": .1}, {"V3max": .5}, {"V3max": 1}, {"V3max": -.1}, {"V3max": -.5},
                                       {"V2max": .1}, {"V2max": .5}, {"V2max": 1}, {"V2max": -.1}, {"V2max": -.5}]

        # self.wt_ss = []
        # self.wt_dynamic = []
        self.perturbation_ss = {}
        # self.perturbation_dynamic = []
        self.estimated_parameters = []
        self.estimate_ids = []

    def create_parameter_list(self, estimate_info):
        """create name value pairs of estimated parameters followed by list of all parameters for use in validation"""
        # create dictionary (of length n_p) of parameters
        number_estimates = len(estimate_info['data_sets'])
        parameter_name_value_pair = [dict(zip(estimate_info['parameter_names'],
                                              [estimate_info['parameter_values'][i_parameter][i_estimate]
                                               for i_parameter, _ in enumerate(estimate_info['parameter_names'])]))
                                     for i_estimate in range(0, number_estimates)]

        # create list of all parameter values of size n_p with each of the above estimated values
        parameter_list = [self.i_parameter for _ in parameter_name_value_pair]
        # data_set_id = []
        estimate_data_set_info = []
        for i_index, i_value in enumerate(parameter_list):
            # data_set_id.append(estimate_info['data_sets'][i_index])
            # estimate_id.append('estimate_{}'.format(i_index))
            estimate_data_set_info.append(('estimate_{}'.format(i_index), estimate_info['data_sets'][i_index][0],
                                           estimate_info['data_sets'][i_index][1]))
            for i_key in parameter_name_value_pair[i_index].keys():
                i_value[i_key] = parameter_name_value_pair[i_index][i_key]

        return parameter_list, estimate_data_set_info

    @staticmethod
    def separate_initial_perturbation(all_sim_results):
        """separate initial ss simulations from perturbation simulation
        for further processing of perturbation sims"""

        initial_sims = []
        perturbation_sims = []

        for j_result in all_sim_results:
            if j_result['initial']:
                initial_sims.append(j_result)
            elif j_result['perturbation']:
                perturbation_sims.append(j_result)

        return initial_sims, perturbation_sims

    @staticmethod
    def separate_ss_dyn(all_results):
        """get ss and dynamic information separately"""

        ss_info = []
        dynamic_info = []

        for j_result in all_results:
            ss_info.append(j_result['ss'])
            dynamic_info.append(j_result['dynamic'])

        return ss_info, dynamic_info

    @staticmethod
    def __create_ss_dict(ss_info, variable_type, noise=0):
        """create dictionary of ss values (concentration/fluxes)"""
        number_variables = len(ss_info[0])
        variable_name_info = [variable_name(variable_type, j_variable) for j_variable in range(0, number_variables)]

        variable_value_info = []

        for j_variable in range(0, number_variables):
            j_variable_info = []
            for i_experiment_id, i_experiment_info in enumerate(ss_info):
                j_variable_info.append(i_experiment_info[j_variable])
            variable_value_info.append(j_variable_info)

        return variable_name_info, variable_value_info

    def __convert_to_ss_dict_for_df(self, ss_info):
        """convert ss information to dictionary for creating df and writing to file"""

        # create dict of perturbation_ss values for writing to df and file
        # concentrations
        y_names, y_values = self.__create_ss_dict(ss_info=[i_ss['y'] for i_ss in ss_info],
                                                  variable_type='metabolite', noise=self.noise)
        y_dict = dict(zip(y_names, y_values))

        # fluxes
        f_names, f_values = self.__create_ss_dict(ss_info=[i_ss['flux'] for i_ss in ss_info],
                                                  variable_type='flux', noise=self.noise)
        f_dict = dict(zip(f_names, f_values))

        # get stable ss information
        final_ss_id = [j_ss_info['ssid'] for j_ss_info in ss_info]
        final_ss_dict = {'final_ss': final_ss_id}

        # get data set details
        # get estimate id
        estimate_id = [j_ss_info['estimate_id'] for j_ss_info in ss_info]

        # get sample id
        sample_id = [j_ss_info['sample_id'] for j_ss_info in ss_info]

        # get data set id
        data_set_id = [j_ss_info['data_set_id'] for j_ss_info in ss_info]

        # get perturbation id
        perturbation_id = [j_ss_info['perturbation_id'] for j_ss_info in ss_info]

        # collate into single dict
        details_dict = dict(zip(['estimate_id', 'sample_name', 'data_set_id', 'perturbation_id'],
                                [estimate_id, sample_id, data_set_id, perturbation_id]))

        # get everything into single dictionary
        ss_info_dict = {}
        ss_info_dict.update(y_dict)
        ss_info_dict.update(f_dict)
        ss_info_dict.update(final_ss_dict)
        ss_info_dict.update(details_dict)

        self.perturbation_ss = ss_info_dict

        return None

    def __add_initial_ss_id(self, initial_ss):
        """add ss_id from initial wt sims to data dict"""

        wt_ss_id = [j_ss_info['ssid'] for j_data in self.perturbation_ss['estimate_id']
                    for j_ss_info in initial_ss if j_data == j_ss_info['estimate_id']]

        # get ss_id information for initial_ss
        # wt_ss_id = [j_ss_info['ssid'] for j_ss_info in initial_ss]
        wt_ss_dict = {'initial_ss': wt_ss_id}

        self.perturbation_ss.update(wt_ss_dict)

        return None

    def create_ss_perturbation_dict(self, all_results):
        """create complete dictionary of details to be converted to df for writing to file"""

        # separate initial simulation values from perturbation simulation values
        initial_sims, perturbation_sims = self.separate_initial_perturbation(all_results)

        # get initial ss values only
        initial_ss, _ = self.separate_ss_dyn(initial_sims)

        # get perturbation ss values only
        perturbation_ss, _ = self.separate_ss_dyn(perturbation_sims)

        self.__convert_to_ss_dict_for_df(perturbation_ss)

        # add ss_id information for initial_ss
        self.__add_initial_ss_id(initial_ss)

        return None

    def create_df(self, all_results, dummy_arg=[]):
        """create df from validation data information in all results"""
        self.create_ss_perturbation_dict(all_results)

        # convert info to multi index data frame for storage and retrieval
        ss_info = self.perturbation_ss
        df_index_tuple = [(i_estimate, i_sample, i_data_set, i_perturbation)
                          for i_estimate, i_sample, i_data_set, i_perturbation in
                          zip(ss_info['estimate_id'], ss_info['sample_name'], ss_info['data_set_id'],
                              ss_info['perturbation_id'])]
        # df_index_tuples = [(i_value_sample, i_value_exp) for i_value_sample, i_value_exp in
        #                    zip(self.perturbation_ss["sample_name"], self.perturbation_ss["experiment_id"])]
        multi_index_labels = ['estimate_id', 'sample_name', 'data_set_id', 'experiment_id']
        index = pd.MultiIndex.from_tuples(df_index_tuple, names=multi_index_labels)

        # remove unused column headings from dictionary
        del self.perturbation_ss["estimate_id"]
        del self.perturbation_ss["sample_name"]
        del self.perturbation_ss["data_set_id"]
        del self.perturbation_ss["perturbation_id"]

        # create data frame
        all_ss_df = pd.DataFrame(self.perturbation_ss, index=index, columns=self.perturbation_ss.keys())

        import pdb;pdb.set_trace()
        print('What to do next?\n')

        return all_ss_df, multi_index_labels
