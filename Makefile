dev:        ## run server on 3001 (watch)
	PORT=3001 pnpm dev:server
db-up:      ## start Postgres+pgvector (Docker)
	docker compose up -d
db-down:    ## stop DB
	docker compose down
db-psql:    ## psql into DB
	docker compose exec -it db psql -U postgres -d pocketgm
logs:       ## tail server log (if backgrounded)
	tail -f /tmp/pocketgm.log
stop:       ## kill server on :3001
	-kill -9 $$(lsof -ti :3001)
