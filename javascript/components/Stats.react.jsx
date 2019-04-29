import React from 'react';
import PropTypes from 'prop-types';

import '../styles/Stats';

var p = (l, n) => n === 1 ? l : l + 's';

export default class Stats extends React.Component {
  render() {
    return (
      <div className="stats">
        <div className="stat">
          <div className="stat__count">{ this.props.repos }</div>
          <div className="stat__name">{ p('repo', this.props.repos) }</div>
        </div>

        <div className="stat">
          <div className="stat__count">{ this.props.followers }</div>
          <div className="stat__name">{ p('follower', this.props.followers) }</div>
        </div>

        <div className="stat">
          <div className="stat__count">{ this.props.streak }{ this.props.streak > 15 ? <span className="octicon octicon-flame notification" /> : '' }</div>
          <div className="stat__name">{ p('day', this.props.streak) } streak</div>
        </div>

        <div className="stat">
          <div className="stat__count">{ this.props.today }{ !this.props.today ? <span className="octicon octicon-stop notification" /> : '' }</div>
          <div className="stat__name">{ p('commit', this.props.today) } today</div>
        </div>
      </div>
    );
  }
}

Stats.propTypes = {
  repos: PropTypes.number.isRequired,
  followers: PropTypes.number.isRequired,
  streak: PropTypes.number.isRequired,
  today: PropTypes.number.isRequired
}
