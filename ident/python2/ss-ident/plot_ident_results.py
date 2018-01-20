import numpy as np
import matplotlib.pyplot as plt
from kotte_model import ident_parameter_name
from kotte_model import kotte_experiment_type_name
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


def experiment_type_plot(position_based_info, fraction_info, x_label, fig_title=''):
    """plot figure for each parameter with info for one parameter provided in input"""
    # figure for parameter i
    f, ax = plt.subplots(1, 3, sharey='row')
    if fig_title:
        f.text(.5, .975, fig_title, horizontalalignment='center', verticalalignment='top')
    for i_position, axis_obj in enumerate(ax):
        x_data = np.array(position_based_info["mean"][i_position])
        x_error = np.array(position_based_info["std"][i_position])
        y_data = np.arange(x_data.shape[0])
        y_tick_names = kotte_experiment_type_name(y_data)
        # prepare annotation
        percent_mean = fraction_info["mean"][i_position]
        percent_error = fraction_info["std"][i_position]
        annotation_text = ["{:.2%}+{:.2f}".format(percent_mean[j_plot_obj], percent_error[j_plot_obj]*100)
                           for j_plot_obj in range(0, len(y_data))]
        axis_obj.barh(y_data, x_data, xerr=x_error, align='center', color='blue', ecolor='black')
        for j_bar in range(0, len(y_data)):
            an1 = axis_obj.annotate("", xy=(x_data[j_bar]/2, y_data[j_bar]), xycoords='data',
                                    xytext=(x_data[j_bar]/2, y_data[j_bar]), textcoords='data')
            an2 = axis_obj.annotate(annotation_text[j_bar], xy=(5, .5), xycoords=an1,
                                    xytext=(12, 0), textcoords="offset points",
                                    size=20, va="center", ha="center")
        axis_obj.set_yticks(y_data)
        axis_obj.set_yticklabels(y_tick_names)
        axis_obj.set_title('experiment {}'.format(i_position))
    ax[-1].invert_yaxis()
    ax[-2].set_xlabel(x_label)
    plt.tight_layout(pad=3.0)
    plt.show()
    return None


def parameter_experiment_type_plot(total_exp_info, fraction_exp_info, parameter_choice=()):
    """call experiment_type_plot for each parameter information present in parameter_position_based_info"""
    if not parameter_choice:
        parameter_choice = range(0, len(total_exp_info))
    for i_parameter in parameter_choice:
        parameter_name = ident_parameter_name(i_parameter)
        experiment_type_plot(total_exp_info[i_parameter], fraction_exp_info[i_parameter],
                             x_label='Occurrence in Identifying Data set',
                             fig_title=parameter_name)
        # experiment_type_plot(i_parameter_info["occurrence total percentage"],
        #                      x_label='Occurrence Percentage in Identifying Data set')
    return None


def flux_parameter_plot(total_ident_data, fraction_data={}, file_destination=()):
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
        if fraction_data:
            lst_data[pos] = {'names': [parameter_name[ind] for ind in boolean_id],
                             'mean': [total_ident_data["means"][ind] for ind in boolean_id],
                             'std': [total_ident_data["std"][ind] for ind in boolean_id],
                             'fraction mean': [fraction_data["means"][ind] for ind in boolean_id],
                             'fraction std': [fraction_data["std"][ind] for ind in boolean_id]}
        else:
            lst_data[pos] = {'names': [parameter_name[ind] for ind in boolean_id],
                             'mean': [total_ident_data["means"][ind] for ind in boolean_id],
                             'std': [total_ident_data["std"][ind] for ind in boolean_id]}

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
    # allow pyplot to use tex for text rendering
    # plt.rc('text', usetex=True)
    plt.rc('font', **{'family': 'sans-serif', 'sans-serif': ['Helvetica']})

    # set figure size and quality
    # f = plt.figure(figsize=(18, 16), dpi=300, facecolor='w', edgecolor='k')
    f, axarr = plt.subplots(nrows, ncolumns, sharex='col',
                            figsize=(8, 6), dpi=100, facecolor='w', edgecolor='k')
    total_plots = 0
    for iplot, axis_obj in enumerate(axarr):
        relevant_dict = lst_data[iplot]
        x_data = np.array(relevant_dict["mean"])
        x_error = np.array(relevant_dict["std"])
        y_data = np.arange(len(relevant_dict["names"]))
        x_percentage_annotation = relevant_dict["fraction mean"]
        x_error_annotation = relevant_dict["fraction std"]
        # create annotations for each bar in each plot
        x_annotation = []
        for i_plot_object in range(0, len(y_data)):
            x_annotation.append("{:.2f} + {:.2f} /%".format(x_percentage_annotation[i_plot_object],
                                                          x_error_annotation[i_plot_object]))
        axis_obj.barh(y_data, x_data, xerr=x_error, align='center', color='green', ecolor='black')
        for j_bar in range(0, len(y_data)):
            an1 = axis_obj.annotate("", xy=(x_data[j_bar], y_data[j_bar]), xycoords='data',
                                    xytext=(x_data[j_bar], y_data[j_bar]), textcoords='data')
            an2 = axis_obj.annotate(x_annotation[j_bar], xy=(5, .5), xycoords=an1,
                                    xytext=(40, 0), textcoords="offset points",
                                    size=20, va="center", ha="center")
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


def plot_on_axis_object(axis_obj, x_data, y_data, x_error, x_percent_mean, x_percent_std):
    """given axis object plot given data on axis object along with all given annotations"""
    # plot bar graphs for x_data vs y_data with x_error error bars
    axis_obj.barh(y_data, x_data, xerr=x_error, align='center', color='blue', ecolor='black')

    # annotate percentages onto each bar in the graph
    for j_bar in range(0, len(y_data)):
        x_annotation = "{:.2f} + {:.2f} %".format(x_percent_mean[j_bar],
                                                  x_percent_std[j_bar])
        an1 = axis_obj.annotate("", xy=(x_data[j_bar], y_data[j_bar]), xycoords='data',
                                xytext=(x_data[j_bar], y_data[j_bar]), textcoords='data')
        an2 = axis_obj.annotate(x_annotation, xy=(5, .5), xycoords=an1,
                                xytext=(40, 0), textcoords="offset points", size=16, va="center", ha="center")
    # set y axis ticks
    axis_obj.set_yticks(y_data)
    # set y axis tick labels (parameter names)
    return None


def parameter_identifibaility_plot(flux_based_parameter_ident):
    """plot parameter identifibaility (number of data combinations identifying
    each parameter in each flux. Paramerers for each flux are plotted in separate subplots"""
    all_sample_all_flux_processed_info = flux_based_parameter_ident["processed"]
    number_of_fluxes = len(all_sample_all_flux_processed_info)
    number_of_subplots = number_of_fluxes
    number_of_columns = 1

    # get figure subplots
    f, axarr = plt.subplots(number_of_subplots, number_of_columns, sharex='col',
                            figsize=(8, 6), dpi=100, facecolor='w', edgecolor='k')
    try:
        for i_flux, i_axis_obj in enumerate(axarr):
            i_flux_info = all_sample_all_flux_processed_info[i_flux]
            x_data = i_flux_info["total"]["mean"]
            x_error = i_flux_info["total"]["std"]
            y_data = np.arange(0, len(x_data))
            x_percent_mean = i_flux_info["percentage"]["mean"]
            x_percent_std = i_flux_info["percentage"]["std"]
            # get parameter id/name for y-axis labels
            flux_name = ["flux{}".format(i_flux_info["total"]["flux id"])]*len(y_data)
            parameter_name = ident_parameter_name(y_data, flux_name=flux_name)
            # plot and annotate using plotting function defined above
            plot_on_axis_object(i_axis_obj, x_data, y_data, x_error, x_percent_mean, x_percent_std)
            # set y-axis tick labels
            i_axis_obj.set_yticklabels(parameter_name)
            # set axis title
            i_axis_obj.set_title('v{} parameters'.format(i_flux_info["total"]["flux id"]))
            # invert y-axis
            i_axis_obj.invert_yaxis()
        # set x-axis label
        axarr[-1].set_xlabel('Number of data combinations used for identification')
        # hide x axis tick labels for all but the last subplot sharing x-axes
        plt.setp([a.get_xticklabels() for a in axarr[0:-2]], visible=False)
    except TypeError:
        for i_flux in range(0, number_of_fluxes):
            i_flux_info = all_sample_all_flux_processed_info[i_flux]
            x_data = i_flux_info["total"]["mean"]
            x_error = i_flux_info["total"]["std"]
            y_data = np.arange(0, len(x_data))
            x_percent_mean = i_flux_info["percentage"]["mean"]
            x_percent_std = i_flux_info["percentage"]["std"]
            # get parameter id/name for y-axis labels
            flux_name = ["flux{}".format(i_flux_info["total"]["flux id"])] * len(y_data)
            parameter_name = ident_parameter_name(y_data, flux_name=flux_name)
            # plot and annotate using plotting function defined above
            plot_on_axis_object(axarr, x_data, y_data, x_error, x_percent_mean, x_percent_std)
            # set y-axis tick labels
            axarr.set_yticklabels(parameter_name)
            # set axis title
            axarr.set_title('v{} parameters'.format(i_flux_info["total"]["flux id"]))
            # invert y-axis
            axarr.invert_yaxis()
        # set x-axis label
        axarr.set_xlabel('Number of data combinations used for identification')
    plt.show()
    return None


def parameter_experiment_info_plot(flux_based_experiment_info):
    """plot position based contribution from each experiment towards
    identifiable data combinations for each parameter for each flux"""
    all_sample_all_flux_processed_info = flux_based_experiment_info["processed"]
    number_of_fluxes = len(all_sample_all_flux_processed_info)
    for j_flux, j_flux_data in enumerate(all_sample_all_flux_processed_info):
        number_of_parameters_in_flux = len(j_flux_data)
        for k_parameter, k_parameter_data in enumerate(j_flux_data):
            number_of_experiment_positions = len(k_parameter_data)
            number_of_subplots = number_of_experiment_positions
            number_of_rows = 1
            f, axarr = plt.subplots(number_of_rows, number_of_subplots, sharey='row',
                                    figsize=(8, 6), dpi=100, facecolor='w', edgecolor='k')
            # get parameter name for figure title
            parameter_name = ident_parameter_name(k_parameter,
                                                  flux_name="flux{}".format(k_parameter_data[0]["total"]["flux id"]))
            # set figure title to parameter name
            figure_title = "flux {}".format(k_parameter_data[0]["total"]["flux id"]) + " " + parameter_name
            f.text(.5, .975, figure_title, horizontalalignment='center', verticalalignment='top')
            try:
                for i_position, i_axis_obj in enumerate(axarr):
                    x_data = k_parameter_data[i_position]["total"]["mean"]
                    y_data = np.arange(0, len(x_data))
                    x_error = k_parameter_data[i_position]["total"]["std"]
                    x_percent_mean = k_parameter_data[i_position]["percentage"]["mean"]
                    x_percent_error = k_parameter_data[i_position]["percentage"]["std"]
                    # get y-axis labels (experiment types)
                    y_tick_labels = kotte_experiment_type_name(y_data)
                    # plot and annotate using plotting function defined above
                    plot_on_axis_object(i_axis_obj, x_data, y_data, x_error, x_percent_mean, x_percent_error)
                    # set axis title
                    i_axis_obj.set_title('experiment {}'.format(i_position + 1))
                # set x-axis label
                axarr[-1].set_xlabel('Frequency of Experiment Appearance')
                # set y-axis tick label
                axarr[0].set_yticklabels(y_tick_labels)
                # invert y-axis
                axarr[0].invert_yaxis()
            except TypeError:
                for i_position in range(0, number_of_experiment_positions):
                    x_data = k_parameter_data[i_position]["total"]["mean"]
                    y_data = np.arange(0, len(x_data))
                    x_error = k_parameter_data[i_position]["total"]["std"]
                    x_percent_mean = k_parameter_data[i_position]["percentage"]["mean"]
                    x_percent_error = k_parameter_data[i_position]["percentage"]["std"]
                    # plot and annotate using plotting function defined above
                    plot_on_axis_object(axarr, x_data, y_data, x_error, x_percent_mean, x_percent_error)
                    # set axis title
                    axarr.set_title('experiment {}'.format(i_position + 1))
                # set x-axis label
                axarr.set_xlabel('Number of data combinations used for identification')
                # set y-axis tick label
                axarr[0].set_yticklabels(y_tick_labels)
                # invert y-axis
                axarr.invert_yaxis()
    plt.show()
    return None


def data_utility_plot(data_list):
    # collect data for plotting
    x_data = data_list["number_parameters_ided"]
    y_data = [len(all_indices) for all_indices in data_list["index"]]
    y_percentage = ["{:.2%}".format(percent_data/100) for percent_data in data_list["percentage"]]
    figure, ax = plt.subplots()
    width = 0.5  # bar width
    ax.bar(x_data, y_data, width, color='blue', align='center', ecolor='black')
    for j_bar in range(0, len(y_data)):
        ax.annotate(y_percentage[j_bar], xy=(x_data[j_bar]-width/2, y_data[j_bar]+.5), xycoords='data',
                    xytext=(x_data[j_bar]-width/2, y_data[j_bar]+.5), textcoords='data')
    ax.set_ylabel('Number of data sets')
    ax.set_xlabel('Number of identified parameters')
    ax.set_xticks(x_data)
    ax.set_title('No Title yet')
    plt.show()

    return None
