#!/bin/bash

# L2Scan Stack - Docker Image Build Script
# This script builds Docker images for frontend and indexer services

set -e

# Configuration
FRONTEND_DIR="../l2scan-ce"
INDEXER_DIR="../l2scan-indexer-ce"
REGISTRY="l2scan"
VERSION=${VERSION:-latest}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if directory exists
check_directory() {
    local dir=$1
    local name=$2
    
    if [ ! -d "$dir" ]; then
        log_error "$name directory not found at $dir"
        log_info "Please ensure the following directory structure:"
        log_info "  l2scan-stack-ce/"
        log_info "  l2scan-ce/"
        log_info "  l2scan-indexer-ce/"
        exit 1
    fi
}

# Function to build Docker image
build_image() {
    local context_dir=$1
    local image_name=$2
    local dockerfile=$3
    
    log_info "Building $image_name..."
    
    if [ ! -f "$context_dir/$dockerfile" ]; then
        log_error "Dockerfile not found: $context_dir/$dockerfile"
        return 1
    fi
    
    # Build the image
    docker build \
        -t "$REGISTRY/$image_name:$VERSION" \
        -t "$REGISTRY/$image_name:latest" \
        -f "$context_dir/$dockerfile" \
        "$context_dir"
    
    if [ $? -eq 0 ]; then
        log_info "Successfully built $REGISTRY/$image_name:$VERSION"
    else
        log_error "Failed to build $REGISTRY/$image_name:$VERSION"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --frontend-only    Build only frontend image"
    echo "  -i, --indexer-only     Build only indexer image" 
    echo "  -v, --version VERSION  Set image version (default: latest)"
    echo "  -r, --registry REG     Set registry name (default: l2scan)"
    echo "  -p, --push            Push images to registry after building"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     # Build both frontend and indexer"
    echo "  $0 -f                  # Build only frontend"
    echo "  $0 -v v1.0.0          # Build with specific version"
    echo "  $0 -p                  # Build and push to registry"
}

# Parse command line arguments
FRONTEND_ONLY=false
INDEXER_ONLY=false
PUSH_IMAGES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--frontend-only)
            FRONTEND_ONLY=true
            shift
            ;;
        -i|--indexer-only)
            INDEXER_ONLY=true
            shift
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -p|--push)
            PUSH_IMAGES=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
log_info "Starting L2Scan Docker image build process..."
log_info "Registry: $REGISTRY"
log_info "Version: $VERSION"

# Check directories exist
if [ "$FRONTEND_ONLY" != true ]; then
    check_directory "$INDEXER_DIR" "Indexer"
fi

if [ "$INDEXER_ONLY" != true ]; then
    check_directory "$FRONTEND_DIR" "Frontend"
fi

# Build images
if [ "$INDEXER_ONLY" != true ]; then
    log_info "Building frontend image..."
    build_image "$FRONTEND_DIR" "frontend" "Dockerfile"
fi

if [ "$FRONTEND_ONLY" != true ]; then
    log_info "Building indexer image..."
    build_image "$INDEXER_DIR" "indexer" "Dockerfile"
fi

# Push images if requested
if [ "$PUSH_IMAGES" = true ]; then
    log_info "Pushing images to registry..."
    
    if [ "$INDEXER_ONLY" != true ]; then
        docker push "$REGISTRY/frontend:$VERSION"
        docker push "$REGISTRY/frontend:latest"
    fi
    
    if [ "$FRONTEND_ONLY" != true ]; then
        docker push "$REGISTRY/indexer:$VERSION"
        docker push "$REGISTRY/indexer:latest"
    fi
    
    log_info "Images pushed successfully!"
fi

# Summary
log_info "Build process completed successfully!"
log_info "Built images:"

if [ "$INDEXER_ONLY" != true ]; then
    log_info "  - $REGISTRY/frontend:$VERSION"
    log_info "  - $REGISTRY/frontend:latest"
fi

if [ "$FRONTEND_ONLY" != true ]; then
    log_info "  - $REGISTRY/indexer:$VERSION" 
    log_info "  - $REGISTRY/indexer:latest"
fi

log_info ""
log_info "To start the stack with these images:"
log_info "  cd docker-compose && make up"