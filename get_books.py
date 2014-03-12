#!/usr/bin/python
# -*- coding: utf-8 -*-
import requests
import json
import os
import time
import csv

def get_sets():
    r = requests.get('https://www.oysterbooks.com/api/sets?limit=1000')
    j = json.loads(r.content)
    with open( os.path.join('data', 'sets.json'), 'w') as f:
        f.write(r.content)
    print json.dumps(j, indent=2)
    return j

def get_books(set_info):
    time.sleep(3)
    set_id = set_info['uuid']
    num_books = set_info['books_count']
    r = requests.get('https://www.oysterbooks.com/api/set/books?set_uuid=%s&limit=%d' % (set_id, num_books + 1))
    j = json.loads(r.content)
    print json.dumps(j, indent=2)
    with open( os.path.join('data', 'books-%s.json' % set_id), 'w') as f:
        f.write(r.content)
    return j

def flatten_dict(d, s =''):
    new = {}
    for k, v in d.items():
        key = s + k
        if isinstance(v, dict):
            new.update(flatten_dict(v, key + '_'))
        else:
            if isinstance(v, basestring):
                new[key] = v.encode('utf-8').strip()
            else:
                new[key] = v
    return new

def to_csv(json_file):
    with open(json_file, 'r') as f:
        j = json.loads(f.read())
        jf = [flatten_dict(x) for x in j]
        with open( json_file.replace('.json', '.csv'), 'w') as g:
            writer = csv.DictWriter(g, fieldnames=jf[0].keys())
            writer.writeheader()
            writer.writerows(jf)

# book_sets = get_sets()
# all_books = []
# for book_set in book_sets:
#     books = get_books(book_set)
#     all_books.extend( books )

# with open( os.path.join('data', 'all-books.json'), 'w') as f:
#     f.write( json.dumps(all_books, indent=2) )

# for book in all_books:
#     print book['book']['title'], book['book']['author'], book['book']['status'], book['book']['isbn']

to_csv( os.path.join('data', 'all-books.json') )

#d <- csv.read('/Users/danielgoldin/Dropbox/dev/web/oyster-books-crawl/data/all-books.csv', header=TRIE,