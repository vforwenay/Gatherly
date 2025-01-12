# Use the official Ruby base image
FROM ruby:3.3.1

# Install dependencies
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
  build-essential \
  libpq-dev \
  git \
  curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/*

# Install the specific version of Bundler
RUN gem install bundler -v 2.5.14

# Set environment variable for the application home directory
ENV APP_HOME /app

# Create necessary directories
RUN mkdir -p $APP_HOME/tmp/cache $APP_HOME/tmp/pids $APP_HOME/tmp/sockets $APP_HOME/log

# Switch to the application directory
WORKDIR $APP_HOME

# Copy Gemfile and Gemfile.lock first to cache dependencies
COPY Gemfile Gemfile.lock ./

# Configure Bundler environment variables
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

# Install gems
RUN bundle install

# Precompile Bootsnap cache for faster startup
RUN bundle exec bootsnap precompile --gemfile

# Copy the application code
COPY . .

# Expose the application port
EXPOSE 3000

# Add a non-root user
RUN adduser --disabled-login appuser
USER appuser

# Define the default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]