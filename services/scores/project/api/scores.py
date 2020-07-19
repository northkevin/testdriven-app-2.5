# services/scores/project/api/scores.py


from sqlalchemy import exc
from flask import Blueprint, request, jsonify
from flask_restful import Resource, Api

from project import db
from project.api.models import Score
from project.api.utils import authenticate_restful, ensure_authenticated


scores_blueprint = Blueprint('scores', __name__)
api = Api(scores_blueprint)

@scores_blueprint.route('/scores/ping', methods=['GET'])
def ping_pong():
    return jsonify({
        'status': 'success',
        'message': 'pong!'
    })

class ScoreList(Resource):
    method_decorators = {'post': [authenticate_restful]}

    # /scores GET
    # authenticated? = No
    def get(self):
        """Get all scores"""
        response_object = {
            'status': 'success',
            'data': {
                'scores': [
                    score.to_json() for score in Score.query.all()
                ]
            }
        }
        return response_object, 200

    # /scores POST
    # authenticated? = Yes
    def post(self, resp):
        """add a new score"""
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
        user_id = post_data.get('user_id')
        exercise_id = post_data.get('exercise_id')
        correct = post_data.get('correct')

        # do db stuff
        try:
            db.session.add(Score(
                user_id=user_id, exercise_id=exercise_id, correct=correct)
            )
            db.session.commit()
            response_object['status'] = 'success'
            response_object['message'] = 'New score was added!'
            return response_object, 201
        except exc.IntegrityError:
            db.session.rollback()
            return response_object, 400
        except (exc.IntegrityError, ValueError):
            db.session.rollback()
            return response_object, 400

class ScoreViaExercise(Resource):

    method_decorators = {'put': [authenticate_restful]}

    def put(self, resp, exercise_id):
        """Update score"""
        post_data = request.get_json()
        response_object = {
            'status': 'fail',
            'message': 'Invalid payload.'
        }
        if not post_data:
            return response_object, 400
        correct = post_data.get('correct')
        try:
            score = Score.query.filter_by(
                exercise_id=int(exercise_id),
                user_id=int(resp['data']['id'])
            ).first()
            if score:
                score.correct = correct
                db.session.commit()
                response_object['status'] = 'success'
                response_object['message'] = 'Score was updated!'
                return response_object, 200
            else:
                db.session.add(Score(
                    user_id=resp['data']['id'],
                    exercise_id=int(exercise_id),
                    correct=correct))
                db.session.commit()
                response_object['status'] = 'success'
                response_object['message'] = 'New score was added!'
                return response_object, 201
        except (exc.IntegrityError, ValueError, TypeError):
            db.session().rollback()
            return response_object, 400

api.add_resource(ScoreList, '/scores')

api.add_resource(ScoreViaExercise, '/scores/<exercise_id>')