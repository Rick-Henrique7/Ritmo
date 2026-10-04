"""Gera as imagens SVG da documentação no estilo editorial do Ritmo.

Uso: python docs/assets/gerar_imagens.py docs/assets <n_unitarios> <n_widget>
"""
import math
import sys

CREAM = "#EDE5D8"; PAPER = "#F6F0E6"; INK = "#2E2D2B"; INK2 = "#6E685F"
CORAL = "#E4553F"; PANEL = "#3B3A39"; ONPANEL = "#F2EBE0"; ONPANEL2 = "#B5AEA3"; LINE = "#D3C8B8"
FONT = "Jost, Futura, 'Century Gothic', 'Avenir Next', 'Segoe UI', Arial, sans-serif"
MONO = "Consolas, Menlo, 'DejaVu Sans Mono', monospace"


def head(w, h, title, desc):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-labelledby="t d">
<title id="t">{title}</title><desc id="d">{desc}</desc>
<defs>
  <pattern id="zig" width="9" height="7" patternUnits="userSpaceOnUse">
    <path d="M0 4.5 L2.25 1.5 L4.5 4.5 L6.75 1.5 L9 4.5" fill="none" stroke="{INK}" stroke-width="1" stroke-opacity=".6"/>
  </pattern>
</defs>
<style>
  text {{ font-family: {FONT}; fill: {INK}; }}
  .eyebrow {{ font-size: 15px; font-weight: 400; letter-spacing: .3px; }}
  .title {{ font-size: 34px; font-weight: 300; }}
  .h {{ font-size: 18px; font-weight: 500; }}
  .s {{ font-size: 13.5px; fill: {INK2}; }}
  .n {{ font-size: 15px; font-weight: 500; fill: {CORAL}; }}
  .on {{ fill: {ONPANEL}; }}
  .onm {{ fill: {ONPANEL2}; }}
  .mono {{ font-family: {MONO}; }}
</style>
<rect width="{w}" height="{h}" fill="{CREAM}"/>
'''


def header(x, y, w, eyebrow, title):
    return f'''<line x1="{x}" y1="{y}" x2="{x + w}" y2="{y}" stroke="{INK}" stroke-opacity=".55"/>
<text x="{x}" y="{y + 27}" class="eyebrow">Ritmo · engenharia</text>
<line x1="{x}" y1="{y + 40}" x2="{x + w}" y2="{y + 40}" stroke="{INK}" stroke-opacity=".55"/>
<text x="{x}" y="{y + 74}" class="eyebrow" style="font-weight:300;font-size:17px">{eyebrow}</text>
<text x="{x}" y="{y + 110}" class="title">{title}</text>
'''


def arrowhead(x, y, deg, color=CORAL, s=9):
    return (f'<polygon points="{s},0 {-s * 0.7:.1f},{s * 0.65:.1f} {-s * 0.7:.1f},{-s * 0.65:.1f}" '
            f'fill="{color}" transform="translate({x:.1f} {y:.1f}) rotate({deg:.1f})"/>')


def ciclo():
    W, H = 1200, 860
    cx, cy, R = 600, 500, 235
    s = head(W, H, "Ciclo de vida de desenvolvimento do Ritmo",
             "Seis fases em ciclo: planejar, projetar, implementar, testar, revisar e integrar, lançar; "
             "o feedback do lançamento volta para o planejamento.")
    s += f'<circle cx="{W - 30}" cy="30" r="150" fill="{CORAL}"/>'
    s += f'<circle cx="{W - 120}" cy="130" r="120" fill="none" stroke="{INK}" stroke-opacity=".5"/>'
    s += f'<circle cx="80" cy="{H - 70}" r="64" fill="url(#zig)"/>'
    s += header(48, 40, 560, "Como o app é construído", "Ciclo de vida de desenvolvimento")
    s += f'<circle cx="{cx}" cy="{cy}" r="{R}" fill="none" stroke="{INK}" stroke-width="1.3"/>'
    for k in range(6):
        a = math.radians(-60 + 60 * k)
        s += arrowhead(cx + R * math.cos(a), cy + R * math.sin(a), math.degrees(a) + 90)
    s += f'<circle cx="{cx}" cy="{cy}" r="112" fill="{PANEL}"/>'
    s += f'<text x="{cx}" y="{cy - 22}" text-anchor="middle" class="on" style="font-size:15px">modelo</text>'
    s += f'<text x="{cx}" y="{cy + 10}" text-anchor="middle" class="on" style="font-size:26px;font-weight:300">iterativo e</text>'
    s += f'<text x="{cx}" y="{cy + 42}" text-anchor="middle" class="on" style="font-size:26px;font-weight:300">incremental</text>'
    phases = [("Planejar", "requisitos, histórias,", "backlog priorizado"),
              ("Projetar", "arquitetura, ADRs,", "protótipo visual"),
              ("Implementar", "branch por etapa,", "commits convencionais"),
              ("Testar", "unitários, widget,", "teste no aparelho"),
              ("Revisar e integrar", "diff revisado,", "merge na main"),
              ("Lançar", "build assinado,", "Play Store + feedback")]
    for k, (t, l1, l2) in enumerate(phases):
        a = math.radians(-90 + 60 * k)
        x, y = cx + R * math.cos(a), cy + R * math.sin(a)
        s += f'<circle cx="{x:.1f}" cy="{y:.1f}" r="30" fill="{CREAM}" stroke="{INK}" stroke-width="1.3"/>'
        s += f'<circle cx="{x:.1f}" cy="{y:.1f}" r="22" fill="{CORAL}"/>'
        s += f'<text x="{x:.1f}" y="{y + 6:.1f}" text-anchor="middle" style="font-size:17px;font-weight:500;fill:{PAPER}">{k + 1:02d}</text>'
        c, sn = math.cos(a), math.sin(a)
        if abs(c) < 0.2:
            anchor, tx = "middle", x
            ty = y - 92 if sn < 0 else y + 58
        else:
            anchor = "start" if c > 0 else "end"
            tx, ty = x + (46 if c > 0 else -46), y - 12
        s += f'<text x="{tx:.1f}" y="{ty:.1f}" text-anchor="{anchor}" class="h">{t}</text>'
        s += f'<text x="{tx:.1f}" y="{ty + 21:.1f}" text-anchor="{anchor}" class="s">{l1}</text>'
        s += f'<text x="{tx:.1f}" y="{ty + 39:.1f}" text-anchor="{anchor}" class="s">{l2}</text>'
    s += f'<text x="{W - 48}" y="{H - 30}" text-anchor="end" class="s">Cada volta entrega uma versão utilizável (v0.1 → v0.2 → …)</text>'
    return s + '</svg>\n'


def pipeline():
    W, H = 1200, 600
    s = head(W, H, "Do commit ao release",
             "Fluxo de uma mudança: ideia, branch, commits, verificação, merge na main, tag de versão, "
             "build assinado e publicação em faixas na Play Console.")
    s += f'<circle cx="{W + 20}" cy="{H - 10}" r="160" fill="{CORAL}"/>'
    s += f'<circle cx="{W - 140}" cy="80" r="46" fill="url(#zig)"/>'
    s += header(48, 40, 620, "Fluxo de uma mudança", "Do commit ao release")
    steps = [("Ideia", "issue ou item", "do backlog"), ("Branch", "feat/ · fix/", "refactor/"),
             ("Commits", "Conventional", "Commits"), ("Verificar", "flutter analyze", "flutter test"),
             ("Merge", "revisão do diff", "na main"), ("Tag", "vX.Y.Z", "+ CHANGELOG"),
             ("Build", "AAB assinado", "(release)"), ("Play Console", "interna → fechada", "→ produção")]
    x0, y0, gap, bw = 48, 290, 140, 122
    for i, (t, a, b) in enumerate(steps):
        x = x0 + i * gap
        panel = i in (3, 6)
        s += (f'<rect x="{x}" y="{y0}" width="{bw}" height="150" rx="24" '
              f'fill="{PANEL if panel else PAPER}" stroke="{PANEL if panel else LINE}"/>')
        s += f'<text x="{x + 18}" y="{y0 + 34}" class="n">{i + 1:02d}</text>'
        ch, cs = ("h on", "s onm") if panel else ("h", "s")
        s += f'<text x="{x + 18}" y="{y0 + 70}" class="{ch}" style="font-size:16.5px">{t}</text>'
        s += f'<text x="{x + 18}" y="{y0 + 98}" class="{cs}" style="font-size:12px">{a}</text>'
        s += f'<text x="{x + 18}" y="{y0 + 116}" class="{cs}" style="font-size:12px">{b}</text>'
        if i < len(steps) - 1:
            ax = x + bw
            s += f'<line x1="{ax + 2}" y1="{y0 + 75}" x2="{ax + gap - bw - 9}" y2="{y0 + 75}" stroke="{INK}" stroke-width="1.3"/>'
            s += arrowhead(ax + gap - bw - 5, y0 + 75, 0, CORAL, 6)
    mid = lambda i: x0 + i * gap + bw / 2
    s += (f'<path d="M{mid(3)} {y0 + 150} C {mid(3)} {y0 + 215}, {mid(2)} {y0 + 215}, {mid(2)} {y0 + 158}" '
          f'fill="none" stroke="{CORAL}" stroke-width="1.4" stroke-dasharray="5 5"/>')
    s += arrowhead(mid(2), y0 + 156, -90, CORAL, 7)
    s += f'<text x="{(mid(2) + mid(3)) / 2}" y="{y0 + 232}" text-anchor="middle" class="s">falhou? corrige e volta</text>'
    s += (f'<path d="M{mid(7)} {y0} C {mid(7)} {y0 - 80}, {mid(0)} {y0 - 80}, {mid(0)} {y0 - 8}" '
          f'fill="none" stroke="{INK}" stroke-opacity=".55" stroke-width="1.2" stroke-dasharray="2 5"/>')
    s += arrowhead(mid(0), y0 - 6, 90, INK, 6)
    s += f'<text x="{(mid(0) + mid(7)) / 2}" y="{y0 - 66}" text-anchor="middle" class="s">o feedback dos usuários vira uma nova ideia</text>'
    return s + '</svg>\n'


def piramide(unit, widget, integ):
    W, H = 1100, 720
    s = head(W, H, "Pirâmide de testes do Ritmo",
             f"Base: {unit} testes unitários de domínio e controllers; meio: {widget} teste de widget; "
             f"topo: {integ} testes de integração, planejados.")
    s += f'<circle cx="{W + 40}" cy="{H + 30}" r="200" fill="{CORAL}"/>'
    s += f'<circle cx="{W - 90}" cy="90" r="58" fill="url(#zig)"/>'
    s += header(48, 40, 600, "Estratégia de qualidade", "Pirâmide de testes")
    ax, ay, base_y, half = 340, 210, 650, 290

    def xat(y):
        return half * (y - ay) / (base_y - ay)

    bands = [(ay, 360, INK, "E2E / integração", f"{integ} hoje · planejado", "fluxos completos no aparelho"),
             (360, 500, PANEL, "Widget", f"{widget} hoje · etapa 2", "telas e componentes isolados"),
             (500, base_y, CORAL, "Unitários", f"{unit} testes", "regras de domínio, modelos, controllers")]
    for i, (y1, y2, col, t, c, d) in enumerate(bands):
        top = y1 + (4 if i else 0)
        a, b = xat(top), xat(y2)
        s += f'<polygon points="{ax - a:.1f},{top} {ax + a:.1f},{top} {ax + b:.1f},{y2} {ax - b:.1f},{y2}" fill="{col}"/>'
        ym = (y1 + y2) / 2 + 12
        s += f'<line x1="{ax + xat(ym) + 14:.1f}" y1="{ym - 6:.1f}" x2="690" y2="{ym - 6:.1f}" stroke="{INK}" stroke-opacity=".45"/>'
        s += f'<circle cx="690" cy="{ym - 6:.1f}" r="3.5" fill="{INK}"/>'
        s += f'<text x="710" y="{ym - 14:.1f}" class="h" style="font-size:20px">{t}</text>'
        s += f'<text x="710" y="{ym + 8:.1f}" class="n" style="font-size:14px">{c}</text>'
        s += f'<text x="710" y="{ym + 28:.1f}" class="s">{d}</text>'
    s += f'<text x="{ax}" y="{base_y + 40}" text-anchor="middle" class="s">mais rápidos e baratos embaixo · mais realistas em cima</text>'
    return s + '</svg>\n'


def camadas():
    W, H = 1200, 800
    s = head(W, H, "Arquitetura em camadas do Ritmo",
             "Presentation depende de Data, que depende de Domain. Data implementa as interfaces de repositório "
             "do Domain sobre SharedPreferences. Core oferece providers, serviços, tema e utilitários a todas as camadas.")
    s += f'<circle cx="{W + 10}" cy="-10" r="160" fill="{CORAL}"/>'
    s += header(48, 40, 640, "Como o código se organiza", "Arquitetura em camadas")
    X, Wb = 48, 800
    layers = [(210, "Presentation", "telas e widgets — leem estado e disparam ações",
               "dashboard_screen · habits_screen · tasks_screen", False),
              (360, "Data", "controllers Riverpod + implementações dos repositórios",
               "TasksNotifier · PrefsTasksRepository · stats_providers", False),
              (510, "Domain", "modelos, regras puras e contratos — sem I/O, sem Riverpod",
               "TaskModel · TaskSchedule · HabitStreak · TasksRepository", True)]
    for y, t, d, e, dark in layers:
        s += f'<rect x="{X}" y="{y}" width="{Wb}" height="112" rx="26" fill="{PANEL if dark else PAPER}" stroke="{PANEL if dark else LINE}"/>'
        ch, cs = ("h on", "s onm") if dark else ("h", "s")
        s += f'<text x="{X + 30}" y="{y + 42}" class="{ch}" style="font-size:22px;font-weight:400">{t}</text>'
        s += f'<text x="{X + 30}" y="{y + 68}" class="{cs}">{d}</text>'
        s += f'<text x="{X + 30}" y="{y + 90}" class="{cs} mono" style="font-size:12px">{e}</text>'
    for y in (322, 472):
        s += f'<line x1="{X + Wb / 2}" y1="{y + 2}" x2="{X + Wb / 2}" y2="{y + 28}" stroke="{INK}" stroke-width="1.4"/>'
        s += arrowhead(X + Wb / 2, y + 31, 90, CORAL, 7)
        s += f'<text x="{X + Wb / 2 + 14}" y="{y + 22}" class="s" style="font-size:12px">depende de</text>'
    s += f'<rect x="{X + 470}" y="680" width="330" height="66" rx="33" fill="none" stroke="{INK}" stroke-dasharray="4 4"/>'
    s += f'<text x="{X + 635}" y="719" text-anchor="middle" class="h" style="font-size:16px">SharedPreferences (JSON)</text>'
    s += (f'<path d="M{X + Wb} 430 H{X + Wb + 18} V713 H{X + 808}" fill="none" '
          f'stroke="{INK}" stroke-opacity=".6" stroke-dasharray="3 4"/>')
    s += arrowhead(X + 806, 713, 180, INK, 6)
    s += f'<text x="{X + 610}" y="660" class="s" style="font-size:12px">Prefs*Repository grava aqui</text>'
    s += f'<text x="{X + 30}" y="660" class="s" style="font-size:12.5px">Data implementa as interfaces do Domain (inversão de dependência)</text>'
    cx = X + Wb + 36
    s += f'<rect x="{cx}" y="210" width="268" height="412" rx="26" fill="{CORAL}"/>'
    s += f'<text x="{cx + 28}" y="254" style="font-size:22px;fill:{PAPER}">Core</text>'
    items = ["providers de infraestrutura", "(armazenamento, hoje, relógio,", "vibração, som, tela acesa)", "",
             "tema e paleta por estilo", "widgets compartilhados", "utilitários de data e JSON"]
    for i, t in enumerate(items):
        s += f'<text x="{cx + 28}" y="{294 + i * 26}" style="font-size:14px;fill:{PAPER}">{t}</text>'
    s += f'<text x="{cx + 28}" y="580" style="font-size:12.5px;fill:{PAPER};opacity:.85">usado por todas as camadas;</text>'
    s += f'<text x="{cx + 28}" y="598" style="font-size:12.5px;fill:{PAPER};opacity:.85">não importa nenhuma feature</text>'
    return s + '</svg>\n'


def timer():
    """Contar tiques × calcular pelo horário de término."""
    W, H = 1200, 700
    s = head(W, H, "Timer de foco: contar tiques ou calcular pelo horário de término",
             "Antes, o timer descontava um segundo a cada tique; em segundo plano os tiques param e o tempo "
             "atrasa. Agora ele guarda o horário de término e calcula o restante pelo relógio a cada tique.")
    s += f'<circle cx="{W + 20}" cy="20" r="150" fill="{CORAL}"/>'
    s += f'<circle cx="{W - 120}" cy="110" r="100" fill="none" stroke="{INK}" stroke-opacity=".5"/>'
    s += header(48, 40, 640, "Refatoração · etapa 3", "Timer pelo horário de término")
    X0, X1 = 120, 1080
    gap0, gap1 = 470, 820

    def lane(y, titulo, sub, depois):
        out = f'<text x="48" y="{y - 52}" class="h" style="font-size:20px">{titulo}</text>'
        out += f'<text x="48" y="{y - 30}" class="s">{sub}</text>'
        out += f'<line x1="{X0}" y1="{y}" x2="{gap0}" y2="{y}" stroke="{INK}" stroke-width="1.3"/>'
        out += f'<line x1="{gap0}" y1="{y}" x2="{gap1}" y2="{y}" stroke="{INK}" stroke-opacity=".5" stroke-dasharray="3 6"/>'
        out += f'<line x1="{gap1}" y1="{y}" x2="{X1}" y2="{y}" stroke="{INK}" stroke-width="1.3"/>'
        for x in range(X0, gap0, 22):
            out += f'<line x1="{x}" y1="{y - 7}" x2="{x}" y2="{y + 7}" stroke="{CORAL}" stroke-width="2"/>'
        for x in range(gap1, X1, 22):
            out += f'<line x1="{x}" y1="{y - 7}" x2="{x}" y2="{y + 7}" stroke="{CORAL}" stroke-width="2"/>'
        out += f'<rect x="{gap0 + 20}" y="{y - 22}" width="{gap1 - gap0 - 40}" height="44" rx="22" fill="{PAPER}" stroke="{LINE}"/>'
        out += f'<text x="{(gap0 + gap1) / 2}" y="{y + 5}" text-anchor="middle" class="s">app em segundo plano · sem tiques</text>'
        out += f'<text x="{X0}" y="{y + 36}" class="s mono" style="font-size:12px">09:00 iniciar</text>'
        out += f'<text x="{X1 - 52}" y="{y + 36}" text-anchor="end" class="s mono" style="font-size:12px">09:25 fim real</text>'
        return out

    y1 = 330
    s += lane(y1, "Antes · contava tiques", "remaining = remaining − 1 a cada segundo recebido", False)
    s += f'<circle cx="{X1}" cy="{y1}" r="40" fill="{PANEL}"/>'
    s += f'<text x="{X1}" y="{y1 + 6}" text-anchor="middle" class="on mono" style="font-size:15px">12:40</text>'
    s += f'<text x="{X1 - 52}" y="{y1 - 50}" text-anchor="end" class="n">ainda faltam 12 min no mostrador</text>'

    y2 = 560
    s += lane(y2, "Agora · horário de término", "endsAt = início + 25 min; restante = endsAt − agora (PomodoroCycle.secondsLeft)", True)
    s += f'<circle cx="{X1}" cy="{y2}" r="40" fill="{CORAL}"/>'
    s += f'<text x="{X1}" y="{y2 + 6}" text-anchor="middle" class="mono" style="font-size:15px;fill:{PAPER}">00:00</text>'
    s += f'<text x="{X1 - 52}" y="{y2 - 50}" text-anchor="end" class="n">sessão concluída e gravada às 09:25</text>'
    return s + '</svg>\n'


if __name__ == "__main__":
    out = sys.argv[1]
    unit, widget = int(sys.argv[2]), int(sys.argv[3])
    for name, svg in [("ciclo-de-vida.svg", ciclo()), ("do-commit-ao-release.svg", pipeline()),
                      ("piramide-de-testes.svg", piramide(unit, widget, 0)),
                      ("arquitetura-camadas.svg", camadas()),
                      ("etapa-3-timer.svg", timer())]:
        with open(f"{out}/{name}", "w", encoding="utf-8") as f:
            f.write(svg)
    print("ok")
