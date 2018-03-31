import { get, post } from './http';

const baseUrl = '/api/v1';

const routes = {
  taxa: `${baseUrl}/taxa`
};

const createTaxa = (body) => {
  return post('/taxa', { body })
}

export default {
  routes,
  createTaxa
}
