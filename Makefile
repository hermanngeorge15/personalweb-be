.PHONY: build up down logs seed smoke ps restart test-email

build:
	./gradlew bootJar -x test --no-daemon

up: build
	docker compose up -d --build

down:
	docker compose down -v

logs:
	docker compose logs -f be

ps:
	docker compose ps

seed:
	docker compose exec -T db psql -U personal -d personal -c \
	"insert into post(slug,title,excerpt,content_mdx,tags,status,published_at) \
	 values('hello-world','Hello','Intro','## Hi',array['web'],'published',now()) \
	 on conflict do nothing;"

smoke:
	./scripts/smoke.sh

test-email:
	./scripts/test-email.sh

restart:
	docker compose restart be


