import 'package:get/get.dart';
import '../models/dizimista_model.dart';

class DizimistaController extends GetxController {
  final _dizimistas = <Dizimista>[].obs;
  final _isLoading = false.obs;
  
  List<Dizimista> get dizimistas => _dizimistas;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    fetchDizimistas();
  }
  
  Future<void> fetchDizimistas() async {
    _isLoading.value = true;
    try {
      // Simulando carregamento de dados
      await Future.delayed(const Duration(seconds: 1));

      // Dados de exemplo
      _dizimistas.assignAll([
        Dizimista(
          id: 1,
          nome: "Maria Silva",
          cpf: "123.456.789-00",
          telefone: "(11) 99999-1234",
          email: "maria.silva@email.com",
          rua: "Rua das Flores",
          numero: "123",
          bairro: "Centro",
          cidade: "Iporá",
          estado: "GO",
          cep: "75200-000",
          estadoCivil: "Casado",
          nomeConjugue: "José Silva",
          dataCasamento: DateTime(1995, 5, 15),
          dataNascimento: DateTime(1980, 3, 20),
          dataNascimentoConjugue: DateTime(1978, 8, 10),
          sexo: "Feminino",
          observacoes: "Membro ativo da pastoral",
          consentimento: true,
          status: "Ativo",
          dataRegistro: DateTime(2022, 1, 14),
        ),
        Dizimista(
          id: 2,
          nome: "João Santos",
          cpf: "987.654.321-00",
          telefone: "(11) 98888-5678",
          email: "joao.santos@email.com",
          rua: "Av. Principal",
          numero: "500",
          bairro: "Vila Nova",
          cidade: "Iporá",
          estado: "GO",
          cep: "75200-100",
          estadoCivil: "Solteiro",
          dataNascimento: DateTime(1990, 7, 12),
          sexo: "Masculino",
          observacoes: "Interessado em participar da pastoral da juventude",
          consentimento: true,
          status: "Ativo",
          dataRegistro: DateTime(2023, 3, 9),
        ),
        Dizimista(
          id: 3,
          nome: "Ana Oliveira",
          cpf: "456.789.123-00",
          telefone: "(11) 97777-4321",
          email: "ana.oliveira@email.com",
          rua: "Rua do Campo",
          numero: "45",
          bairro: "Jardim Primavera",
          cidade: "Iporá",
          estado: "GO",
          cep: "75200-200",
          estadoCivil: "Viúvo",
          dataNascimento: DateTime(1975, 11, 25),
          sexo: "Feminino",
          observacoes: "Viúva, participa regularmente das celebrações",
          consentimento: true,
          status: "Afastado",
          dataRegistro: DateTime(2021, 11, 4),
        ),
        Dizimista(
          id: 4,
          nome: "Pedro Costa",
          cpf: "321.654.987-00",
          telefone: "(11) 96666-9876",
          email: "pedro.costa@email.com",
          rua: "Alameda dos Anjos",
          numero: "77",
          bairro: "Parque das Acácias",
          cidade: "Iporá",
          estado: "GO",
          cep: "75200-300",
          estadoCivil: "Casado",
          nomeConjugue: "Carla Costa",
          dataNascimento: DateTime(1985, 2, 8),
          dataNascimentoConjugue: DateTime(1987, 12, 30),
          dataCasamento: DateTime(2010, 8, 20),
          sexo: "Masculino",
          observacoes: "Novo membro da comunidade",
          consentimento: true,
          status: "Novo Contribuinte",
          dataRegistro: DateTime(2024, 1, 19),
        ),
        Dizimista(
          id: 5,
          nome: "Lúcia Ferreira",
          cpf: "147.258.369-00",
          telefone: "(11) 95555-1111",
          email: "lucia.ferreira@email.com",
          rua: "Beco da Paz",
          numero: "8",
          bairro: "Vila Esperança",
          cidade: "Iporá",
          estado: "GO",
          cep: "75200-400",
          estadoCivil: "Separado",
          dataNascimento: DateTime(1970, 9, 5),
          sexo: "Feminino",
          observacoes: "Afastada temporariamente por motivos pessoais",
          consentimento: true,
          status: "Inativo",
          dataRegistro: DateTime(2020, 5, 14),
        ),
      ]);
    } catch (e) {
      print("Erro ao carregar dizimistas: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> addDizimista(Dizimista dizimista) async {
    _isLoading.value = true;
    try {
      // Simulando adição
      await Future.delayed(const Duration(seconds: 1));

      // Atribui um novo ID baseado no timestamp para garantir unicidade
      _dizimistas.add(dizimista.copyWith(id: DateTime.now().millisecondsSinceEpoch));
    } catch (e) {
      print("Erro ao adicionar dizimista: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> updateDizimista(Dizimista dizimista) async {
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _dizimistas.indexWhere((d) => d.id == dizimista.id);
      if (index != -1) {
        _dizimistas[index] = dizimista;
      }
    } catch (e) {
      print("Erro ao atualizar dizimista: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> deleteDizimista(int id) async {
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _dizimistas.removeWhere((d) => d.id == id);
    } catch (e) {
      print("Erro ao deletar dizimista: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  List<Dizimista> searchDizimistas(String query) {
    if (query.isEmpty) return _dizimistas;

    final queryLower = query.toLowerCase().trim();
    return _dizimistas.where((dizimista) {
      return dizimista.nome.toLowerCase().contains(queryLower) ||
             dizimista.cpf.contains(query) ||
             dizimista.telefone.contains(query) ||
             (dizimista.email?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.rua?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.numero?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.bairro?.toLowerCase().contains(queryLower) ?? false) ||
             dizimista.cidade.toLowerCase().contains(queryLower) ||
             dizimista.estado.toLowerCase().contains(queryLower) ||
             (dizimista.cep?.contains(query) ?? false) ||
             (dizimista.nomeConjugue?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.estadoCivil?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.observacoes?.toLowerCase().contains(queryLower) ?? false) ||
             dizimista.status.toLowerCase().contains(queryLower);
    }).toList();
  }
}