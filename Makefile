dev:      ## run server on 3001
	PORT=3001 pnpm dev:server
db-up:    ## start Postgres
	docker compose up -d
db-psql:  ## psql into DB
	docker compose exec -it db psql -U postgres -d pocketgm
