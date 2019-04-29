// React types
import React from 'react';
// import { Router, Route } from "react-router";
import { BrowserRouter as Router, Route } from 'react-router-dom';
import ReactDOM from 'react-dom';

// Custom components
import Login from './Login.react';
import Profile from './Profile.react';
import Following from './Following.react';

ReactDOM.render((
  <Router>
    <div className="github-pulse">
      <Route path="/" component={Login} />
      <Route path="/:username" component={Profile} />
      <Route path="/compare/following/:username" component={Following} />
    </div>
  </Router>),
  document.getElementById('github-pulse')
);
