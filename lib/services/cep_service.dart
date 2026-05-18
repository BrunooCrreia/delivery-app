import 'package:projeto_perguntas/services/address_service.dart';

class CepService {
  CepService({AddressService? addressService})
    : _addressService = addressService ?? AddressService();

  final AddressService _addressService;

  Future<Map<String, dynamic>> fetchAddress(String cep) {
    return _addressService.getAddressByCep(cep);
  }
}
