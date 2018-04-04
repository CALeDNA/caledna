import { get, put } from './http';

const baseUrl = '/api/v1';

const routes = {
  taxa: `${baseUrl}/taxa`
};

const createUpdateTaxa = (id, body) => {
  return put(`${id}/update_create`, { body })
}

export default {
  routes,
  createUpdateTaxa
}
