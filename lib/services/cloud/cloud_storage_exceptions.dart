class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateCoctailException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllCoctailsException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateCoctailException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteCoctailException extends CloudStorageException {}
