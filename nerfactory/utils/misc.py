# Copyright 2022 The Plenoptix Team. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Miscellaneous helper code.
"""

import hashlib
import json
from pydoc import locate
from typing import Any, Callable, Dict

from math import floor, log
import torch
from omegaconf import DictConfig


class DotDict(dict):
    """
    dot.notation access to dictionary attributes
    """

    def __getattr__(self, attr):
        return self[attr]

    __setattr__ = dict.__setitem__
    __delattr__ = dict.__delitem__


def get_dict_to_torch(stuff, device="cpu"):
    """Set everything in the dict to the specified torch device."""
    if isinstance(stuff, dict):
        for k, v in stuff.items():
            stuff[k] = get_dict_to_torch(v, device)
        return stuff
    if isinstance(stuff, torch.Tensor):
        return stuff.to(device)
    return stuff


def get_dict_to_cpu(stuff):
    """Set everything in the dict to CPU."""
    if isinstance(stuff, dict):
        for k, v in stuff.items():
            stuff[k] = get_dict_to_cpu(v)
        return stuff
    if isinstance(stuff, torch.Tensor):
        return stuff.detach().cpu()
    return stuff


def is_not_none(var):
    """Return True if the variable var is None."""
    return not isinstance(var, type(None))


def get_masked_dict(d, mask):
    """Return a masked dictionary.
    TODO(ethan): add more asserts/checks so this doesn't have unpredictable behavior."""
    masked_dict = {}
    for key, value in d.items():
        masked_dict[key] = value[mask]
    return masked_dict


def instantiate_from_dict_config(dict_config: DictConfig, **kwargs):
    """Our version of hydra's instantiate function."""
    dict_config_kwargs = {k: v for k, v in dict_config.items() if k != "_target_"}
    uninstantiated_class = locate(dict_config._target_)  # pylint: disable=protected-access
    all_kwargs = dict_config_kwargs
    all_kwargs.update(kwargs)
    instantiated_class = uninstantiated_class(**all_kwargs)
    return instantiated_class


def get_hash_str_from_dict(dictionary: Dict[str, Any]) -> str:
    """MD5 hash of a dictionary. Based on
    https://www.doc.ic.ac.uk/~nuric/coding/how-to-hash-a-dictionary-in-python.html"""
    dhash = hashlib.md5()
    encoded = json.dumps(dictionary, sort_keys=True).encode()
    dhash.update(encoded)
    return dhash.hexdigest()


class IterableWrapper:  # pylint: disable=too-few-public-methods
    """A helper that will allow an instance of a class to return multiple kinds of iterables bound
    to different functions of that class.

    To use this, pass in the instance of the class you want to have multiple kinds of iterables for,
    and pass in a method belonging to that class that you want to be the __next__() method of the
    iterable. The resulting instantiated object will be an iterable that will use the passed in
    class method as the __next__() method.

    Args:
        instance (object): instance class we are wrapping
        new_next (callable): function that will be called instead as the __next__()


    Attributes:
        instance (object): instance class we are wrapping
        new_next (callable): function that will be called instead as the __next__()
    """

    def __init__(self, instance: object, new_next: Callable):
        self.instance = instance
        self.new_next = new_next

    def __next__(self):
        return self.new_next(self.instance)


def human_format(num):
    """Format a number in a more human readable way"""
    units = ["", "K", "M", "B", "T", "P"]
    k = 1000.0
    magnitude = int(floor(log(num, k)))
    return f"{(num / k**magnitude):.2f} {units[magnitude]}"