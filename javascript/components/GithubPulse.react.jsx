import React from 'react';

import '../styles/GithubPulse';

export default class GithubPulse extends React.Component {
  render() {
    return (
      <div className="github-pulse">
        { this.props.children }
      </div>
    );
  }
}
