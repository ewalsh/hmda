"""Function for seeding data."""
import pandas as pd
import numpy as np
import uuid

# reference data for api calls
state_abbr = pd.read_csv('~/Projects/hmda/Rcode/StateAbbrData.csv')
yrs = np.arange(2007, 2018, 1)


def seed_one(state, yr):
    """Seeding one and/or initial data."""
    # functions for data call
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


def test():
    file = pd.read_csv('../data/load/OH2016lar.csv', dtype=object)
    return(file)


# data_lar = data_lar.iloc[:, 1:data_lar.shape[1]]
