# services/exercises/project/api/models.py


from sqlalchemy.sql import func
from flask import current_app

from project import db


class Exercise(db.Model):

    __tablename__ = 'exercises'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    body = db.Column(db.String(255), nullable=False)
    test_code = db.Column(db.String(255), nullable=False)
    test_code_solution = db.Column(db.String(255), nullable=False)

    def __init__(self, body, test_code, test_code_solution):
        self.body = body
        self.test_code = test_code
        self.test_code_solution = test_code_solution
        

    def to_json(self):
        return {
            'id': self.id,
            'body': self.body,
            'test_code': self.test_code,
            'test_code_solution': self.test_code_solution
        }
