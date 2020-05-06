"""Function for seeding data."""
import pandas as pd
import numpy as np
import pycurl
from io import BytesIO

# reference data for api calls
state_abbr = pd.read_csv('~/Projects/hmda/Rcode/StateAbbrData.csv')
yrs = np.arange(2007, 2018, 1)



def seed_one(state, yr):
    """Seeding one and/or initial data."""
    # functions for curl call
    b_obj = BytesIO()
    crl = pycurl.Curl()
    # create url path
    url_base = "https://api.consumerfinance.gov/data/hmda/slice/hmda_lar.csv?$where=state_abbr+%3D+'"
    url_middle = "'+AND+as_of_year+%3D+"
    url_end = "&$limit=0&$offset=0"
    url_full = url_base + state + url_middle + yr + url_end
    # set url
    crl.setopt(crl.URL, url_full)
    # write bytes
    crl.setopt(crl.WRITEDATA, b_obj)
    # file transfer and close
    crl.perform()
    crl.close()
    return(b_obj.getvalue().decode('utf8'))
