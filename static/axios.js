import axios from 'axios';
import Cookies from 'js-cookie';

const host = window.location.host;

const instance = axios.create({
    baseURL: `http://${host}`,
    headers: {"X-CSRFToken": Cookies.get('csrftoken')}
});

export default instance;
