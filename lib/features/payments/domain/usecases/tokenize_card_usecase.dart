import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class TokenizeCardUseCase {
  final CardTokenizerRepository repository;
  const TokenizeCardUseCase(this.repository);

  Future<String> call(CardInput card) => repository.tokenize(card);
}
