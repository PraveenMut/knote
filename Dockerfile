FROM docker-registry.hq.local/ioof/rhel7_node012:latest
COPY . .
RUN npm install
CMD ["npm", "start"]