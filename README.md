# 3-Tier Dockerized Task Manager (DevOps Demo)

A simple **three-tier architecture** project, fully containerized with Docker Compose, ready to deploy on an AWS EC2 instance.

```
┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│  Frontend   │ ───▶ │   Backend    │ ───▶ │   Database   │
│  (Nginx)    │ /api │ (Node/Express)│      │ (PostgreSQL) │
│  port 80    │      │  port 5000   │      │  port 5432   │
└─────────────┘      └──────────────┘      └──────────────┘
```

- **Tier 1 – Presentation**: Static HTML/CSS/JS task manager UI, served by Nginx. Nginx also reverse-proxies `/api/*` calls to the backend, so only port 80 needs to be exposed publicly.
- **Tier 2 – Application/Logic**: Node.js + Express REST API (`/tasks` endpoints: GET, POST, PUT, DELETE).
- **Tier 3 – Data**: PostgreSQL database storing tasks, initialized automatically via `db/init.sql`.

All three tiers run as separate Docker containers on a shared Docker network, connected via `docker-compose.yml`.

## Project structure

```
three-tier-app/
├── docker-compose.yml
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── index.html
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
└── db/
    └── init.sql
```

## 1. Test locally (optional but recommended)

```bash
cd three-tier-app
docker compose up -d --build
```

Then open `http://localhost` in your browser. Add/check/delete a task to confirm the frontend → backend → database chain works.

To stop:
```bash
docker compose down          # stop containers, keep data
docker compose down -v       # stop containers AND wipe the database volume
```

## 2. Deploy on an EC2 instance

### Step 1 — Launch an EC2 instance
- AMI: Ubuntu Server 22.04 LTS (or Amazon Linux 2023)
- Instance type: `t2.micro` (free tier is fine for a demo)
- Security Group inbound rules:
  - **SSH (22)** — your IP only
  - **HTTP (80)** — `0.0.0.0/0` (so the app is reachable)
- Create/select a key pair to SSH in

### Step 2 — SSH into the instance
```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

### Step 3 — Install Docker & Docker Compose
```bash
sudo apt update -y
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
# log out and back in (or run `newgrp docker`) so the group change takes effect
```

Verify:
```bash
docker --version
docker compose version
```

### Step 4 — Copy the project to EC2
From your local machine:
```bash
scp -i your-key.pem -r three-tier-app ubuntu@<EC2_PUBLIC_IP>:~/
```
(Alternatively, push this project to a Git repo and `git clone` it on the instance.)

### Step 5 — Build and run
On the EC2 instance:
```bash
cd three-tier-app
sudo docker compose up -d --build
```

Check everything is running:
```bash
sudo docker compose ps
sudo docker compose logs -f backend    # watch backend logs / DB connection retries
```

### Step 6 — Access the app
Open in your browser:
```
http://<EC2_PUBLIC_IP>
```

You should see the Task Manager UI, backed live by the Postgres database running in its own container.

## Useful commands for your demo/report

```bash
docker compose ps                 # list running containers per tier
docker compose logs backend       # backend/API logs
docker compose logs db            # database logs
docker exec -it db psql -U postgres -d taskdb -c "SELECT * FROM tasks;"   # query DB directly
docker compose down && docker compose up -d --build   # rebuild after code changes
```

## Ideas to extend this for a more advanced submission

- Add a `docker-compose.prod.yml` with resource limits and restart policies
- Push images to Docker Hub / Amazon ECR and pull them on EC2 instead of building on-instance
- Put Nginx behind an AWS Application Load Balancer, run backend on multiple EC2 instances
- Add a CI/CD pipeline (GitHub Actions) that builds images and deploys to EC2 on every push
- Move Postgres to Amazon RDS instead of a container, to show a "managed data tier"
- Add HTTPS via Let's Encrypt/Certbot or an ACM cert on a load balancer
