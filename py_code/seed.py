"""Function for seeding data."""
import pandas as pd
import numpy as np
import uuid
import os

# reference data for api calls
state_abbr = pd.read_csv('~/Projects/hmda/Rcode/StateAbbrData.csv')
yrs = np.arange(2007, 2018, 1)

def lar_pull(state, yr):
    """Pull data from hdma lar."""
    url_base = "https://api.consumerfinance.gov/data/hmda/slice/hmda_lar.csv?$where=state_abbr+%3D+'"
    url_middle = "'+AND+as_of_year+%3D+"
    url_end = "&$limit=0&$offset=0"
    url_full = url_base + state + url_middle + str(yr) + url_end
    data_lar = pd.read_csv(url_full, dtype=object)
    # dropping rows numbers
    ids = {}
    for i in np.arange(0, data_lar.shape[0]):
        ids[i] = uuid.uuid4()

    data_lar['uuid'] = ids.values()
    f_str = '../data/load/hmda_lar.csv'
    data_lar.to_csv(f_str, index=False)
    return(data_lar)


def census_pull(state, yr, data_lar, api_key):
    """Pull data from census."""
    census_base = 'https://api.census.gov/data/2017/cbp?get='
    census_middle = 'COUNTY,EMP,EMPSZES,EMPSZES_LABEL,ESTAB,NAICS2017,NAICS2017_LABEL,PAYANN,STATE,YEAR&for=county:'
    c_ids = data_lar[(data_lar['state_abbr'] == state)]['county_code'].unique()
    state_code = data_lar['state_code'].loc[0]
    c_ids = c_ids[(np.isnan(c_ids.astype(np.float)) == False)].astype(np.integer)
    census_results = []
    for cid in c_ids:
        cid_str = str(cid)
        while(len(cid_str) < 3):
            cid_str = '0' + cid_str

        census_end = """{}&in=state:{}&key={}""".format(cid_str, state_code, api_key)
        census_url = census_base + census_middle + census_end
        census_data = pd.read_json(census_url)
        census_header = census_data.loc[0]
        census_data1 = census_data.loc[1:census_data.shape[0]]
        census_data1.columns = census_header
        census_data1 = census_data1[(census_data1['EMPSZES'] == '001')]
        census_sums = census_data1[['EMP','ESTAB','PAYANN']].apply(pd.to_numeric).sum(axis=0)
        pop_base = 'https://api.census.gov/data/2010/dec/sf1?get='
        pop_middle = 'H010001,NAME&for=county:'
        pop_end = """{}&in=state:{}&key={}""".format(cid_str,state_code,api_key)
        pop_link = pop_base + pop_middle + pop_end
        pop_data = pd.read_json(pop_link)
        cdict = {'state_code': pd.to_numeric(data_lar['state_code'][0]), 'state_abbr': state, \
         'county_code': pd.to_numeric(cid_str), 'county_name': pop_data.iloc[1,1], 'year': yr, \
        'EMP': census_sums['EMP'], 'ESTAB': census_sums['ESTAB'], 'PAYANN': census_sums['PAYANN'], \
        'POP': pd.to_numeric(pop_data.iloc[1,0])}
        census_results.append(cdict)

    census_df = pd.DataFrame(census_results)
    census_df.to_csv('../data/load/hmda_census.csv', index = False)
    return(census_df)


def inst_pull(state, yr):
    """Pull mortgage instituions data"""
    url_base = "https://api.consumerfinance.gov/data/hmda/slice/institutions.csv?where=respondent_state+%3D+'"
    url_middle = "'+AND+activity_year+%3D+"
    url_end = '&limit=0&offset=0'
    url_full = url_base + state + url_middle + str(yr) + url_end
    data_inst = pd.read_csv(url_full, dtype=object)
    data_inst.to_csv('../data/load/hmda_inst.csv')
    return(data_inst)


def seed_one(state, yr, data_lar, api_key):
    """Seeding one and/or initial data."""
    # functions for lar data call
    data_lar = lar_pull(state, yr)
    # functions for census data call
    census_df = census_pull(state, yr, data_lar, api_key)
    return({'lar': data_lar, 'census': census_df})


def test():
    file = pd.read_csv('../data/load/OH2016lar.csv', dtype=object)
    return(file)


# data_lar = data_lar.iloc[:, 1:data_lar.shape[1]]
