import numpy as np
import matplotlib.pyplot as plt
from kotte_model import ident_parameter_name
from kotte_model import experiment_name
from kotte_model import flux_based_id


def data_for_plots(original_data, case=1):
    if case==1:
        all_boolean_p_id = []
        for len_pos, i_list in enumerate(original_data):
            for i_data in i_list:
                boolean_p_id = [True if j_p in i_data["parameter_ids"] else False for j_p in range(0, 12)]
                all_boolean_p_id.append(boolean_p_id)
        number_data, number_p = np.array(all_boolean_p_id).shape
        all_boolean_p_id = [list(j_p) for j_p in np.transpose(np.array(all_boolean_p_id))]
        # get total data identifying each parameter
        all_boolean_p_id_sum = [sum(j_list) for j_list in all_boolean_p_id]
        all_boolean_p_id_fraction = [float(sum(j_list))/number_data for j_list in all_boolean_p_id]
        return all_boolean_p_id_sum, all_boolean_p_id_fraction
    elif case==2:
        all_boolean_p_id = []
        all_boolean_e_id = []
        for len_pos, i_list in enumerate(original_data):
            for i_data in i_list:
                # parameters identified
                boolean_p_id = [True if j_p in i_data["parameter_ids"] else False for j_p in range(0, 12)]
                all_boolean_p_id.append(boolean_p_id)
                # experiments done
                boolean_e_id = [True if j_p in i_data["experiment_id"] else False for j_p in range(0, 18)]
                all_boolean_e_id.append(boolean_e_id)
        all_boolean_p_id = [list(k_p) for k_p in np.transpose(np.array(all_boolean_p_id))]
        # all_boolean_e_id = [list(j_p) for j_p in np.transpose(np.array(all_boolean_e_id))]
        # get total for each experiment in each identifying data set
        # all_boolean_e_id = [sum(k_list) for k_list in all_boolean_e_id]
        return all_boolean_p_id, all_boolean_e_id
    else:
        return []


def useful_experiments(original_data):
    """get most and least useful experiments based on identifiable and non-identifiable datasets"""
    all_boolean_p_id, all_boolean_e_id = data_for_plots(original_data, 2)
    all_parameter_exp_id = []
    for j_p in all_boolean_p_id:
        # get data set for each parameter
        data_id = [i for i, val in enumerate(j_p) if val]
        # get experiments for data in data_id
        exp_id = [[j for j, val in enumerate(all_boolean_e_id[i]) if val] for i in data_id]
        exp_id = np.array(exp_id)
        exp_lst = []
        try:
            for j_exp in range(0, exp_id.shape[1]):
                exp_lst.append(list(np.unique(exp_id[:, j_exp])))
        except IndexError:
            for _ in range(0, 3):
                exp_lst.append([])
        all_exp_total_per_pos = []
        for i_pos, k_exp_pos in enumerate(exp_lst):
            total_each_exp_per_pos = []
            for exp_number in k_exp_pos:
                y = sum([[True if exp_number == i else False for i in j][i_pos] for j in exp_id])
                total_each_exp_per_pos.append(y)
            all_exp_total_per_pos.append(total_each_exp_per_pos)
        all_parameter_exp_id.append({'unique':exp_lst,
                                     'occurrence':all_exp_total_per_pos})
    # get experiment name
    experiment_names = experiment_name(range(0, 18), experiment_details)
    # collect data on the basis of experiments
    lst_data = {'names':experiment_names,
                'data':all_boolean_e_id}
    # f, axob = plt.
    return None


def flux_parameter_plot(total_ident_data, file_destination=()):
    """calculate and plot the number of data identifying each parameter in each flux"""
    # get flux and parameter name for k_p
    flux_name, pid, _ = flux_based_id(range(0, 12))
    parameter_name = ident_parameter_name(pid, flux_name)

    # arrange all data in flux-based dictionary
    unique_flux_names = list(set(flux_name))
    number_of_fluxes = len(unique_flux_names)
    lst_data = [[] for _ in range(number_of_fluxes)]
    for pos, iflux in enumerate(unique_flux_names):
        # get all parameters/fluxes that match iflux in fname
        boolean_id = [j for j, val in enumerate([True if iflux == j_flux else False
                                                 for j_flux in flux_name]) if val]
        # get parameter names for each parameter for each flux in boolean_id (same flux)
        # collect data on the basis of unique fluxes
        lst_data[pos] = {'names':[parameter_name[id] for id in boolean_id],
                         'data':[total_ident_data[id] for id in boolean_id]}

    # plot data for each flux in a separate subplot i.e. number_of_subplots = number_of_fluxes
    nrows = 3
    if number_of_fluxes%3 == 0:
        ncolumns = number_of_fluxes/3
    elif number_of_fluxes%3 == 1:
        ncolumns = (number_of_fluxes - 1)/3
    elif number_of_fluxes%3 == 2:
        ncolumns = (number_of_fluxes + 1) / 3
    else:
        ncolumns = 2
    f, axarr = plt.subplots(nrows, ncolumns, sharex='col')
    total_plots = 0
    for iplot, axis_obj in enumerate(axarr):
        relevant_dict = lst_data[iplot]
        x_data = np.array(relevant_dict["data"])
        y_data = np.arange(len(relevant_dict["names"]))
        axis_obj.barh(y_data, x_data, align='center', color='green', ecolor='black')
        axis_obj.set_yticks(y_data)
        axis_obj.set_yticklabels(relevant_dict["names"])
        axis_obj.invert_yaxis()
        # axis_obj.set_xlabel('Number of Identifying Data Sets')
        axis_obj.set_title(unique_flux_names[iplot])
        total_plots += 1
    axarr[-1].set_xlabel('Number of data sets')
    plt.setp([a.get_xticklabels() for a in axarr[0:-2]], visible=False)
    plt.show()
    if file_destination:
        # save figure to file as png and eps
        plt.savefig(file_destination+'.eps', format='png', dpi=2000)
        plt.savefig(file_destination+'.png', format='eps', dpi=2000)
    return None


def plot_identifiable_parameter(max_parameter):
    ident_data = max_parameter["data"]
    number_parameters = len(ident_data)
    y_pos = np.arange(number_parameters)
    # x_data = ident_data

    plt.rcdefaults()
    fig, ax = plt.subplots()
    ax.barh(y_pos, ident_data, align='center', color='green', ecolor='black')

    parameter_id = [ident_parameter_name(i) for i in range(0, number_parameters)]

    ax.set_yticks(y_pos)
    ax.set_yticklabels(parameter_id)
    ax.invert_yaxis()
    ax.set_xlabel('Number of Identifying Data Sets')
    ax.set_title('Parameter Identifiability')

    #max_ident_value = max_parameter["maximum"]
    #max_ident_data_id = max_parameter["id"]
    # number of datasets identifying maximum parameters
    #unique_parameter_number_identified = np.unique(np.array())

    #number_max_parameter_data = len(max_ident_data_id)
    return None
