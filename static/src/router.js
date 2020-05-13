import React from 'react';
import {Route, Switch, Redirect} from 'react-router-dom';
import Home from "../components/Home/";


export default class MainRoutes extends React.Component {
  /**
    @return {} - Switch components
   */
  render() {
    return (
      <main id="container">
        <Switch>
          <Route path='/' component={Home} />
          <Redirect path='*' to='/' />
        </Switch>
      </main>
    );
  }
}