import { get, post } from './http';

const baseUrl = '/api/v1';

export const routes = {
  taxa: `${baseUrl}/taxa`
};

export const createTaxa = (body) => {
  return post(routes.taxa, { body })
}

// export routes;
