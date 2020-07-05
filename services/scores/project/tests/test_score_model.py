# services/scores/project/tests/test_score_model.py


import unittest

from sqlalchemy.exc import IntegrityError

from project import db
from project.api.models import Score
from project.tests.base import BaseTestCase
from project.tests.utils import add_score


class TestScoreModel(BaseTestCase):

    def test_add_score(self):
        score = add_score(user_id=1,
        exercise_id=2,
        correct=False)
        self.assertTrue(score.id)
        self.assertEqual(score.user_id, 1)
        self.assertEqual(score.exercise_id, 2)
        self.assertEqual(score.correct, False)


if __name__ == '__main__':
    unittest.main()
