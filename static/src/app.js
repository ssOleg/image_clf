import React from 'react';
import {render} from 'react-dom';
import {BrowserRouter as Router} from "react-router-dom";
import createMuiTheme from "@material-ui/core/styles/createMuiTheme";
import { ThemeProvider as MuiThemeProvider } from '@material-ui/core/styles';
import MainRoutes from './router';

const theme = createMuiTheme();
const App = () => (
    <Router>
        <MuiThemeProvider theme={theme}>
            <MainRoutes/>
        </MuiThemeProvider>
    </Router>
);

render(<App />, document.getElementById("app"));
