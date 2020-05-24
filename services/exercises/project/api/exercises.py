# services/exercises/project/api/exercises.py


from sqlalchemy import exc
from flask import Blueprint, request
from flask_restful import Resource, Api

from project import db
from project.api.models import Exercise
from project.api.utils import authenticate_restful, ensure_authenticated


exercises_blueprint = Blueprint('exercises', __name__)
api = Api(exercises_blueprint)


class ExerciseList(Resource):
    method_decorators = {'post': [authenticate_restful]}

    def get(self):
        """Get all exercises"""
        response_object = {
            'status': 'success',
            'data': {
                'exercises': [
                    exercise.to_json() for exercise in Exercise.query.all()
                ]
            }
        }
        return response_object, 200

    def post(self, resp):
        """Save a new exercise"""
        post_data = request.get_json()
        response_object = {
            'status': 'fail',
            'message': 'Invalid payload.'
        }
        #check authorization
        if not ensure_authenticated(resp):
            response_object['message'] = \
                'You do not have permission to do that.'
            return response_object, 401
        #check for valid json body
        post_data = request.get_json()
        if not post_data:
            return response_object, 400

        # init params
        body = post_data.get('body')
        test_code = post_data.get('test_code')
        test_code_solution = post_data.get('test_code_solution')

        # do db stuff
        try:
            db.session.add(Exercise(
                body=body, test_code=test_code, test_code_solution=test_code_solution)
            )
            db.session.commit()
            response_object['status'] = 'success'
            response_object['message'] = 'New exercise was added!'
            return response_object, 201
        except exc.IntegrityError:
            db.session.rollback()
            return response_object, 400
        except (exc.IntegrityError, ValueError):
            db.session.rollback()
            return response_object, 400


api.add_resource(ExerciseList, '/exercises')