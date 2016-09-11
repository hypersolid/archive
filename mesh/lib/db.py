from types import *

class DB:
    ################################################
    # Constructors
    ################################################
    def __init__(self, host="localhost", user="root", passwd="", db="mesh", dry_run=False):
        self.dry_run = dry_run
        if not self.dry_run:
            import MySQLdb
            self.conn = MySQLdb.connect (host=host, user=user, passwd=passwd, db=db)

    def __del__(self):
        if not self.dry_run:
            self.conn.close()

    ################################################
    # DDL
    ################################################
    def execute(self, sql):
        if self.dry_run:
            print sql + ';'
            return sql + ';'
        else:
            cursor = self.conn.cursor()
            cursor.execute(sql)
            rows = cursor.fetchall()
            cursor.close()
            return rows

    def create_table(self, name, fields):
        try:
            self.execute('DROP TABLE IF EXISTS %s' % name)
        except:
            pass
        return self.execute('CREATE TABLE %s (%s)' % (name, fields))
        
    def copy_table(self, name, dup):
        try:
            self.execute('DROP TABLE IF EXISTS %s' % dup)
        except:
            pass
        return self.execute('CREATE TABLE %s SELECT * FROM %s' % (dup, name))
        
    def create_index(self, table, field):
        return self.execute('ALTER TABLE %s ADD INDEX (%s)' % (table, field))

    ################################################
    # Helpers
    ################################################        
    def quote(self, value):
        if type(value) is StringType and value[0]!=' ':
            return '\'' + value + '\''
        return str(value)
        
    ################################################
    # Data creation/deletion
    ################################################
    def insert(self, table, kv):
        k, v = [], []
        for key in kv:
            k.append(key)
            v.append(self.quote(kv[key]))
        sql = 'INSERT INTO %s (%s) VALUES(%s)' % (table, ','.join(k), ','.join(v))
        return self.execute(sql)

    def update(self, table, kv, conditions):
        k, v = [], []
        for key in kv:
            k.append(key + '=' + self.quote(kv[key]))
        sql = 'UPDATE %s SET %s WHERE %s' % (table, ','.join(k), conditions)
        return self.execute(sql)
        
    def delete(self, table, conditions):
        return self.execute('DELETE FROM %s WHERE %s' % (table, conditions))
        
    ################################################
    # Data selection
    ################################################
    def select(self, table, fields='*', condition='1', limit=0, order=''):
        sql = 'SELECT %s from %s where %s' % (fields, table, condition)
        if order:
            sql += ' order by %s' % order
        if limit: 
            sql += ' limit %d' % limit
        return self.execute(sql)
    
    def select_column(self, table, fields='*', condition='1', limit=0, order=''):
        data = self.select(table, fields, condition, limit, order)
        return [row[0] for row in data]

    def select_dict(self, table, fields, condition='1', limit=0, order='', aliases=None):
        data = self.select(table, fields, condition, limit, order)
        keys = aliases and aliases.split(',') or fields.split(',')
        result = {}
        for k in keys:
            result[k] = []
        for row in data:
            for i, k in enumerate(keys):
                result[k].append(row[i])
        return result
    
    def plain_dict(self, sql, fields=''):
        data = self.execute(sql)
        keys = fields.split(',')
        result = {}
        for k in keys:
            result[k] = []
        for row in data:
            for i, k in enumerate(keys):
                result[k].append(row[i])
        return result
