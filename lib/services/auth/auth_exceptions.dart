// Login Exceptions

class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// Register Exceptions

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthExceptions implements Exception {}

// Generic Exceptions

class GenericAuthExceptions implements Exception {}

class UserNotLoggedInExceptions implements Exception {}
