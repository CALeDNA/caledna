 CREATE USER ggbn_export WITH PASSWORD 'password';
 GRANT USAGE ON SCHEMA public TO ggbn_export;

 GRANT SELECT ON public.samples TO ggbn_export;
