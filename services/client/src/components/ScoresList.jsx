import React from "react";

const ScoresList = (props) => {
  return (
    <div>
      <h1 className="title is-1">All Scores</h1>
      <hr />
      <br />
      <table className="table is-hoverable is-fullwidth">
        <thead>
          <tr>
            <th>ID</th>
            <th>USER_ID</th>
            <th>EXERCISE_ID</th>
            <th>CORRECT</th>
          </tr>
        </thead>
        <tbody>
          {props.scores &&
            props.scores.map((score) => {
              return (
                <tr key={score.id}>
                  <td>{score.id}</td>
                  <td>{score.user_id}</td>
                  <td>{score.exercise_id}</td>
                  <td>{String(score.correct)}</td>
                </tr>
              );
            })}
        </tbody>
      </table>
    </div>
  );
};

export default ScoresList;
