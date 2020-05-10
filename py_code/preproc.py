"""Preprocessing of data."""
import pandas as pd
import numpy as np
import math
from sklearn import preprocessing

# ['action_taken', 'applicant_income_000s', 'applicant_race_name_1',
#        'co_applicant_race_name_1', 'applicant_sex', 'lien_status',
#        'loan_purpose', 'loan_type', 'agency_code', 'owner_occupancy',
#        'property_type', 'purchaser_type_name', 'hud_median_family_income',
#        'loan_amount_000s', 'number_of_1_to_4_family_units',
#        'minority_population', 'population', 'tract_to_msamd_income', 'emp',
#        'estab', 'payann', 'pop', 'county_code', 'county_name', 'state_code']

def approve_def(data):
    # create approved variable
    start_obs = data.shape[0]
    data.loc[:,'action_taken'] = pd.to_numeric(data.loc[:,'action_taken'])
    data = data.loc[(data.loc[:,'action_taken'] != 6),:]
    data = data.loc[(data.loc[:,'action_taken'] != 5),:]
    data = data.loc[(data.loc[:,'action_taken'] != 4),:]
    """dropped {} observations""".format(start_obs - data.shape[0])
    return(data)


def remove_nans(data):
    # remove nans
    start_obs = data.shape[0]
    data.loc[:,'applicant_income_000s'] = pd.to_numeric(data.loc[:,'applicant_income_000s'])
    data = data.loc[(data.loc[:,'applicant_income_000s'].apply(lambda x: math.isnan(float(x))) == False),:]
    """dropped {} observations""".format(start_obs - data.shape[0])
    return(data)


def rm_onedollar(data):
    data.loc[:,'applicant_income_000s'] = pd.to_numeric(data.loc[:,'applicant_income_000s'])
    # remove income $1 outliers
    data = data.loc[(data.loc[:,'applicant_income_000s'] != 1),:]
    return(data)


def cat_to_bin(data_series, cat):
    output = np.zeros(data_series.shape[0])
    ids = (data_series == cat)
    output[ids] = 1
    return(output)



def other_race(data_series):
    otherRaceApplicant = np.ones(data.shape[0])
    ids = (data_series == 'White')
    otherRaceApplicant[ids] = 0
    ids = (data_series == 'Black or African American')
    otherRaceApplicant[ids] = 0
    ids = (data_series == 'Asian')
    otherRaceApplicant[ids] = 0
    return(otherRaceApplicant)


def create_wf(data):
    white_friend = np.zeros(data.shape[0])
    ids = (data.loc[:,'applicant_race_name_1'] != 'White') & (data.loc[:,'co_applicant_race_name_1'] == 'White')
    white_friend[ids] = 1
    """{:,.0f} non-white applicants have a white co-applicant""".format(sum(white_friend))
    return(white_friend)


def create_approved(data):
    data['action_taken'] = pd.to_numeric(data['action_taken'])
    approved = np.zeros(data.shape[0])
    ids = (data['action_taken'] == 1) | (data['action_taken'] == 2)
    approved[ids] = 1
    return(approved)

def create_hud_spread(data):
    # create the spread and adjust for value size
    hud_spread = pd.to_numeric(data.loc[:,'applicant_income_000s']) \
     - pd.to_numeric(data.loc[:,'hud_median_family_income'])/1000
    # adjusted spread
    hud_spread = hud_spread+min(hud_spread)*-1 + 0.00001
    # log transform
    hud_spread_log = hud_spread.apply(lambda x: math.log(x))
    hud_spread_log_normalized = preprocessing.scale(hud_spread_log)
    return(hud_spread_log_normalized)


def rm_hud_outliers(data):
    # remove nans
    start_obs = data.shape[0]
    hud_spread = pd.to_numeric(data.loc[:,'applicant_income_000s']) - pd.to_numeric(data.loc[:,'hud_median_family_income'])/1000
    ids = hud_spread.apply(lambda x: math.isnan(float(x)))
    # remove nans
    data = data.loc[(ids == False),:]
    """dropped {} observations""".format(start_obs - data.shape[0])
    return(data)


def income_loan_ratio(data):
    output = pd.to_numeric(data.loc[:,'loan_amount_000s'])/pd.to_numeric(data.loc[:,'applicant_income_000s'])
    output = output.apply(lambda x: math.log(x, 10))
    return(output)


def trans_actions(data):
    data = approve_def(data)
    data = remove_nans(data)
    data = rm_onedollar(data)
    data = rm_hud_outliers(data)
    approved = create_approved(data)
    income_log = pd.to_numeric(data.loc[:,'applicant_income_000s']).apply(lambda x: math.log(x, 10))
    sole_applicant = cat_to_bin(data.loc[:,'co_applicant_race_name_1'], 'No co-applicant')
    black_applicant = cat_to_bin(data.loc[:,'applicant_race_name_1'], 'Black or African American')
    asian_applicant = cat_to_bin(data.loc[:,'applicant_race_name_1'], 'Asian')
    other_applicant = other_race(data.loc[:,'applicant_race_name_1'])
    white_friend = create_wf(data)
    is_female = pd.to_numeric(data.loc[:,'applicant_sex']) - 1
    first_lien = cat_to_bin(data.loc[:,'lien_status'], 1)
    refi = cat_to_bin(data.loc[:,'loan_purpose'], 3)
    home_improve = cat_to_bin(data.loc[:,'loan_purpose'], 2)
    # types of insured mortgages
    fha = cat_to_bin(data.loc[:,'loan_type'], 2)
    va = cat_to_bin(data.loc[:,'loan_type'], 3)
    fsa = cat_to_bin(data.loc[:,'loan_type'], 4)
    # types of agencies
    hud = cat_to_bin(data.loc[:,'agency_code'], 7)
    credit_union = cat_to_bin(data.loc[:,'agency_code'], 5)
    is_ownocc = cat_to_bin(data.loc[:,'owner_occupancy'], 1)
    preapp_req = cat_to_bin(data.loc[:,'preapproval'], 1)
    is_manufac = cat_to_bin(data.loc[:,'property_type'], 2)
    #is_multi = cat_to_bin(data.loc[:,'property_type'], 3)
    # purchaser types
    fnma = cat_to_bin(data.loc[:,'purchaser_type_name'], 'Fannie Mae (FNMA)')
    gnma = cat_to_bin(data.loc[:,'purchaser_type_name'], 'Ginnie Mae (GNMA)')
    fin = cat_to_bin(data.loc[:,'purchaser_type_name'], 'Life insurance company, credit union, mortgage bank, or finance company')
    fhlmc = cat_to_bin(data.loc[:,'purchaser_type_name'], 'Freddie Mac (FHLMC)')
    comm = cat_to_bin(data.loc[:,'purchaser_type_name'], 'Commercial bank, savings bank or savings association')
    private = cat_to_bin(data.loc[:,'purchaser_type_name'], 'Private securitization')
    farmer = cat_to_bin(data.loc[:,'purchaser_type_name'], 'Farmer Mac (FAMC)')
    hud_spread = create_hud_spread(data)
    inc_loan_ratio = income_loan_ratio(data)
    low_density = preprocessing.scale(pd.to_numeric(data.loc[:,'number_of_1_to_4_family_units']))
    self_owned = preprocessing.scale(pd.to_numeric(data.loc[:,'number_of_owner_occupied_units']))
    area_pop = data.loc[:,'population'].apply(lambda x: math.log(x, 10))
    local_income_ratio = preprocessing.scale(pd.to_numeric(data.loc[:,'tract_to_msamd_income']))
    emp_pop = preprocessing.scale(pd.to_numeric(data.loc[:,'emp'])/pd.to_numeric(data.loc[:,'pop']))
    estab_pop = preprocessing.scale(pd.to_numeric(data.loc[:,'estab'])/pd.to_numeric(data.loc[:,'pop']))
    pay_pop = pd.to_numeric(data.loc[:,'payann'])/pd.to_numeric(data.loc[:,'pop'])
    pay_pop = pay_pop.apply(lambda x: math.log(x))
    output = pd.DataFrame({'approved': approved, 'income_log': income_log,
        'sole_applicant': sole_applicant, 'black_applicant': black_applicant,
        'asian_applicant': asian_applicant, 'other_race': other_applicant,
        'white_friend': white_friend, 'is_female': is_female, 'first_lien': first_lien,
        'refinancing': refi, 'home_improve': home_improve, 'is_hud': hud,
        'credit_union': credit_union, 'is_ownocc': is_ownocc, 'preapp_req': preapp_req,
        'is_manufact': is_manufac, 'is_fnma': fnma, 'is_gnma': gnma,
        'is_fin': fin, 'is_fhlmc': fhlmc, 'is_comm': comm, 'is_priv': private,
        'is_farmer': farmer, 'hud_spread': hud_spread, 'inc_loan_ratio': inc_loan_ratio,
        'low_density': low_density, 'self_owned': self_owned, 'area_pop': area_pop,
        'local_income_ratio': local_income_ratio, 'emp_pop': emp_pop, 'estab_pop': estab_pop,
        'pay_pop': pay_pop})
    return(output)
