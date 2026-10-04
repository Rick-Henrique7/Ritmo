# Revisão de arquitetura (01/10/2026)

Diagnóstico feito antes da etapa 1, comparando o código com SOLID e Clean Code.

## Pontos fortes
- Organização por feature com `core/` separado e regras escritas nos READMEs.
- Estado com Riverpod `Notifier`, sem `setState` espalhado.
- Modelos imutáveis com `copyWith`/`toJson`/`fromJson`.
- Persistência isolada em `PrefsStore`, chaves centralizadas.
- Serviços de vibração e som encapsulados.
- Conventional Commits, CHANGELOG e versionamento semântico.

## Problemas encontrados (por gravidade)

| # | Problema | Princípio | Etapa |
| --- | --- | --- | --- |
| 1 | Controllers acessavam `SharedPreferences` direto e acumulavam estado, JSON, gravação e efeitos | SRP, DIP | 1 ✅ |
| 2 | Regras de negócio dentro das telas (Hoje, Estatísticas, calendário) — origem de 3 bugs | SRP, fonte única | 1 ✅ |
| 3 | Providers de infraestrutura dentro de `habits`; ciclo `settings ↔ habits`; provider duplicado | Acoplamento | 1 ✅ |
| 4 | Recorrentes com um único "concluída"; sequência gravada e desatualizada | Modelagem de domínio | 1 ✅ |
| 5 | Timer por decremento (atrasa e para em segundo plano); histórico não reativo; dependências não usadas | Corretude | 1 (histórico) ✅ · 3 (timer, dependências) ✅ |
| 6 | Nenhum teste real; lints padrão | Qualidade | 1 (unitários) ✅ · 2 (widget, lints, CI) ✅ |
| 7 | Arquivos de 900–1.250 linhas; código duplicado; `AppColors` global mutável; `core/` importando features | Clean Code | 3 ✅ |
| 8 | APK versionado no git; docs desatualizados; sem CI | Processo | 2 (APK fora do git, CI) ✅ · 4 |
