"""Preprocessing of data."""
import pandas as pd
import numby as np


def trans_actions(data_lar):
    lar = data_lar[(data_lar['action_taken'] != 6)]
    lar = lar[(lar['action_taken'] != 5)]
    lar = lar[(lar['action_taken'] != 4)]
    """dropped {} observations""".format(data_lar.shape[0] - lar.shape[0])
    return(lar)
