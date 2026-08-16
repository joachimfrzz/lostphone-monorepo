// Lost Phone — Prototype du jalon-duel (D49)
// Verrouillage + Accueil + WhatsApp (conversation « Marc ❤️ », contenu réel de Coches bleues).
// Objectif : juger la fidélité Flutter à l'œil, sur iPhone (build web CanvasKit).
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const LostPhoneProto());

// ————— Palette WhatsApp sombre (métriques design-i2) —————
const waFond = Color(0xFF111B21);
const waPanneau = Color(0xFF202C33);
const waAccent = Color(0xFF00A884);
const waBulleEnvoi = Color(0xFF005C4B);
const waBulleRecu = Color(0xFF202C33);
const waTexte = Color(0xFFE9EDEF);
const waTexte2 = Color(0xFF8696A0);
const cocheBleue = Color(0xFF53BDEB);

class LostPhoneProto extends StatelessWidget {
  const LostPhoneProto({super.key});
  @override
  Widget build(BuildContext context) {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coches bleues — proto',
      theme: base.copyWith(
        textTheme: base.textTheme,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const Cadre(),
    );
  }
}

/// Centre le « téléphone » sur grand écran, plein écran sur mobile.
class Cadre extends StatelessWidget {
  const Cadre({super.key});
  @override
  Widget build(BuildContext context) {
    final l = MediaQuery.of(context).size;
    if (l.width <= 520) return const Verrouillage();
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Center(
        child: Container(
          width: 402,
          height: 874,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(59),
            border: Border.all(color: const Color(0xFF3A3A3C), width: 4),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 90, offset: Offset(0, 35))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(55),
            child: const Verrouillage(),
          ),
        ),
      ),
    );
  }
}

// ============================================================ VERROUILLAGE
class Verrouillage extends StatefulWidget {
  const Verrouillage({super.key});
  @override
  State<Verrouillage> createState() => _VerrouillageState();
}

class _VerrouillageState extends State<Verrouillage> {
  double glisse = 0;

  void _deverrouille() {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, a, __) => const Accueil(),
      transitionsBuilder: (_, a, __, enfant) {
        final courbe = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
            opacity: courbe,
            child: ScaleTransition(
                scale: Tween(begin: 1.08, end: 1.0).animate(courbe), child: enfant));
      },
    ));
    setState(() => glisse = 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _deverrouille,
      onVerticalDragUpdate: (d) =>
          setState(() => glisse = (glisse - d.delta.dy).clamp(0, 220)),
      onVerticalDragEnd: (_) =>
          glisse > 90 ? _deverrouille() : setState(() => glisse = 0),
      child: Transform.translate(
        offset: Offset(0, -glisse * .55),
        child: Scaffold(
          body: Stack(fit: StackFit.expand, children: [
            const DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment(-.6, -1),
                        end: Alignment(.7, 1),
                        colors: [
                  Color(0xFF120E24),
                  Color(0xFF2A1747),
                  Color(0xFF63295C),
                  Color(0xFFC25A52)
                ],
                        stops: [0, .32, .64, 1]))),
            Positioned(top: -80, right: -60, child: _halo(const Color(0xFFFF9E58), 340)),
            Positioned(bottom: -120, left: -80, child: _halo(const Color(0xFF5C36FF), 420)),
            SafeArea(
                child: Column(children: [
              const SizedBox(height: 8),
              const BarreStatut(heure: ''),
              const SizedBox(height: 22),
              const Icon(Icons.lock, color: Colors.white, size: 19),
              const SizedBox(height: 12),
              const Text('lundi 20 juillet',
                  style: TextStyle(
                      color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600)),
              // iOS 16+ : horloge GRASSE (plus la fine d'avant iOS 16)
              const Text('19:47',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 92,
                      fontWeight: FontWeight.w700,
                      height: 1.04,
                      letterSpacing: -2.5)),
              const Spacer(),
              const NotifVerre(
                  couleurIcone: Color(0xFF25D366),
                  icone: Icons.chat,
                  app: 'WhatsApp · Marc ❤️',
                  quand: 'il y a 2 h',
                  corps:
                      'N\'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges co…'),
              const SizedBox(height: 8),
              const NotifVerre(
                  couleurIcone: Color(0xFF34C759),
                  icone: Icons.phone,
                  app: 'Téléphone · Chloé',
                  quand: '19:32',
                  corps: '2 appels manqués'),
              const SizedBox(height: 26),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        RondVerre(icone: Icons.flashlight_on),
                        RondVerre(icone: Icons.camera_alt)
                      ])),
              const SizedBox(height: 24),
              const BarreHome(),
              const SizedBox(height: 8),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _halo(Color c, double taille) => IgnorePointer(
      child: Container(
          width: taille,
          height: taille,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                  colors: [c.withValues(alpha: .45), c.withValues(alpha: 0)]))));
}

class NotifVerre extends StatelessWidget {
  final Color couleurIcone;
  final IconData icone;
  final String app, quand, corps;
  const NotifVerre(
      {super.key,
      required this.couleurIcone,
      required this.icone,
      required this.app,
      required this.quand,
      required this.corps});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                color: Colors.white.withValues(alpha: .20),
                child: Row(children: [
                  Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: couleurIcone, borderRadius: BorderRadius.circular(9)),
                      child: Icon(icone, color: Colors.white, size: 22)),
                  const SizedBox(width: 11),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                          child: Text(app,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600))),
                      Text(quand,
                          style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ]),
                    const SizedBox(height: 2),
                    Text(corps,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .95),
                            fontSize: 14.5,
                            height: 1.25)),
                  ])),
                ]),
              ),
            )),
      );
}

class RondVerre extends StatelessWidget {
  final IconData icone;
  const RondVerre({super.key, required this.icone});
  @override
  Widget build(BuildContext context) => ClipOval(
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
              width: 52,
              height: 52,
              color: const Color(0xFF3C3C3C).withValues(alpha: .5),
              child: Icon(icone, color: Colors.white, size: 22))));
}

class BarreHome extends StatelessWidget {
  const BarreHome({super.key});
  @override
  Widget build(BuildContext context) => Container(
      width: 140,
      height: 5,
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(3)));
}

class BarreStatut extends StatelessWidget {
  final String heure;
  const BarreStatut({super.key, this.heure = '19:47'});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(children: [
          Text(heure,
              style: TextStyle(
                  color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w600)),
          const Spacer(),
          Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                  4,
                  (i) => Container(
                      margin: const EdgeInsets.only(right: 1.5),
                      width: 3,
                      height: 4 + i * 2.3,
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(1))))),
          const SizedBox(width: 5),
          const Icon(Icons.wifi, color: Colors.white, size: 16),
          const SizedBox(width: 5),
          Stack(alignment: Alignment.centerLeft, children: [
            Container(
                width: 27,
                height: 13,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54),
                    borderRadius: BorderRadius.circular(4))),
            Container(
                margin: const EdgeInsets.only(left: 2),
                width: 17,
                height: 9,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(2))),
          ]),
        ]),
      );
}

// ============================================================ ACCUEIL
class Accueil extends StatelessWidget {
  const Accueil({super.key});

  void _ouvreWhatsApp(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, a, __) => const WhatsAppListe(),
        transitionsBuilder: (_, a, __, enfant) {
          final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
          return FadeTransition(
              opacity: c,
              child: ScaleTransition(
                  scale: Tween(begin: .82, end: 1.0).animate(c), child: enfant));
        }));
  }

  @override
  Widget build(BuildContext context) {
    final apps = <(String, Widget)>[
      ('Horloge', _ic(const Color(0xFF1C1C1E), const Icon(Icons.watch_later_outlined, color: Colors.white, size: 30))),
      ('Calendrier', _ic(Colors.white, Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('LUN.', style: TextStyle(color: const Color(0xFFFF3B30), fontSize: 9, fontWeight: FontWeight.w600)),
        Text('20', style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w300, height: 1))
      ]))),
      ('Photos', _ic(Colors.white, const Icon(Icons.filter_vintage, color: Color(0xFFE64980), size: 34))),
      ('Plans', _ic(const Color(0xFF34C3FF), const Icon(Icons.near_me, color: Colors.white, size: 30))),
      ('Météo', _ic(const Color(0xFF54C7FC), const Icon(Icons.wb_sunny, color: Color(0xFFFFD60A), size: 28))),
      ('Notes', _ic(const Color(0xFFFFCC00), const Icon(Icons.edit_note, color: Colors.white, size: 32))),
      ('Rappels', _ic(Colors.white, const Icon(Icons.checklist, color: Color(0xFF0A84FF), size: 30))),
      ('Calculatrice', _ic(const Color(0xFF2C2C2E), const Icon(Icons.calculate_outlined, color: Color(0xFFFF9F0A), size: 30))),
      ('Réglages', _ic(const Color(0xFF8E8E93), const Icon(Icons.settings, color: Colors.white, size: 32))),
      ('Localiser', _ic(const Color(0xFF32D74B), const Icon(Icons.radar, color: Colors.white, size: 28))),
      ('Santé', _ic(Colors.white, const Icon(Icons.favorite, color: Color(0xFFFA5252), size: 28))),
      ('Ma Banque', _ic(const Color(0xFF123E6B), const Icon(Icons.account_balance, color: Colors.white, size: 27))),
    ];
    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
      const DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(-.6, -1),
                  end: Alignment(.7, 1),
                  colors: [
            Color(0xFF0C0919),
            Color(0xFF1D1033),
            Color(0xFF43203F),
            Color(0xFF7C3A35)
          ],
                  stops: [0, .34, .68, 1]))),
      SafeArea(
          child: Column(children: [
        const SizedBox(height: 8),
        const BarreStatut(),
        const SizedBox(height: 14),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      color: const Color(0xFF232032).withValues(alpha: .55),
                      child: Row(children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Lyon',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          Text('24°',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w300,
                                  height: 1.1)),
                        ]),
                        const Spacer(),
                        Text('Nuit dégagée\nMax. 29°  Min. 18°',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: .85),
                                fontSize: 12.5,
                                height: 1.5)),
                      ]),
                    )))),
        const SizedBox(height: 20),
        Expanded(
            child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 8,
                physics: const NeverScrollableScrollPhysics(),
                children: [
              for (final a in apps) AppIcone(nom: a.$1, icone: a.$2),
              AppIcone(
                  nom: 'WhatsApp',
                  badge: '1',
                  onTap: () => _ouvreWhatsApp(context),
                  icone: _ic(const Color(0xFF25D366),
                      const Icon(Icons.chat, color: Colors.white, size: 32))),
            ])),
        ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    color: const Color(0xFF46415A).withValues(alpha: .5),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.search, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text('Recherche',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: .85), fontSize: 12.5)),
                    ])))),
        const SizedBox(height: 14),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        color: const Color(0xFF46415F).withValues(alpha: .42),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AppIcone(
                                  nom: '',
                                  badge: '2',
                                  icone: _ic(const Color(0xFF2FC74F),
                                      const Icon(Icons.phone, color: Colors.white, size: 30))),
                              AppIcone(
                                  nom: '',
                                  icone: _ic(const Color(0xFF2FC74F),
                                      const Icon(Icons.sms, color: Colors.white, size: 28))),
                              AppIcone(
                                  nom: '',
                                  icone: _ic(const Color(0xFF0A84FF),
                                      const Icon(Icons.mail, color: Colors.white, size: 28))),
                              AppIcone(
                                  nom: '',
                                  icone: _ic(const Color(0xFFF2F2F7),
                                      const Icon(Icons.explore,
                                          color: Color(0xFF0A84FF), size: 32))),
                            ]))))),
        const SizedBox(height: 16),
        const BarreHome(),
        const SizedBox(height: 8),
      ])),
    ]));
  }

  static Widget _ic(Color fond, Widget enfant) => Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
          color: fond,
          borderRadius: BorderRadius.circular(14.5),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 3))
          ]),
      child: Center(child: enfant));
}

class AppIcone extends StatelessWidget {
  final String nom;
  final Widget icone;
  final String? badge;
  final VoidCallback? onTap;
  const AppIcone({super.key, required this.nom, required this.icone, this.badge, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap ??
            () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                width: 320,
                backgroundColor: const Color(0xFF28282A),
                content: Text('Prototype-duel : seule WhatsApp est ouverte',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5)),
                duration: const Duration(milliseconds: 1600))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, children: [
            icone,
            if (badge != null)
              Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      height: 23,
                      constraints: const BoxConstraints(minWidth: 23),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30),
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text(badge!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600))))),
          ]),
          if (nom.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(nom,
                style: TextStyle(
                    color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500)),
          ],
        ]),
      );
}

// ============================================================ WHATSAPP (idiome iOS)
// Réf. fidélité : WhatsApp iOS mode sombre — onglets en bas, grand titre,
// bulles arrondies 16, texte 16.5, saisie iOS (+ / champ / caméra / micro).
const waVert = Color(0xFF25D366); // accent iOS (badges, actions)

class WhatsAppListe extends StatelessWidget {
  const WhatsAppListe({super.key});
  @override
  Widget build(BuildContext context) {
    final convs = <(String, Color, String, String, String, String?, bool)>[
      ('M', const Color(0xFF5B7C99), 'Marc ❤️', '17:41',
          "N'oublie pas : 11h30. Après-demain je te tiens dans mes b…", '1', true),
      ('C', const Color(0xFFC76B8F), 'Chloé', '19:33', '📞 Appel vocal manqué', '2', true),
      ('T', const Color(0xFF6B8F71), 'Thomas', 'samedi', '🎤 0:42', null, false),
      ('M', const Color(0xFF8F7C6B), 'Maman', 'dimanche',
          'tu viens dimanche ??? bisous maman', null, false),
      ('M', const Color(0xFF7C6B8F), 'Marie kiné', 'vendredi',
          "✓✓ ok pour l'échange de créneaux jeudi 👍", null, false),
    ];
    return Scaffold(
        backgroundColor: waFond,
        body: SafeArea(
            bottom: false,
            child: Column(children: [
              const SizedBox(height: 8),
              const BarreStatut(),
              // ——— Grand titre iOS + actions rondes
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 16, 4),
                  child: Row(children: [
                    const Text('Discussions',
                        style: TextStyle(
                            color: waTexte,
                            fontSize: 33,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .2)),
                    const Spacer(),
                    _rond(Icons.more_horiz, onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 10),
                    _rond(Icons.camera_alt_outlined),
                    const SizedBox(width: 10),
                    _rond(Icons.add, fond: waVert, couleur: const Color(0xFF0B141A)),
                  ])),
              // ——— Recherche iOS
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                  child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1C242B),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Row(children: [
                        Icon(Icons.search, color: waTexte2, size: 19),
                        SizedBox(width: 6),
                        Text('Rechercher',
                            style: TextStyle(color: waTexte2, fontSize: 16.5)),
                      ]))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Row(children: [
                    _puce('Toutes', true),
                    _puce('Non lues', false),
                    _puce('Favoris', false),
                    _puce('Groupes', false),
                  ])),
              Expanded(
                  child: ListView(padding: EdgeInsets.zero, children: [
                for (final c in convs)
                  LigneConv(
                      initiale: c.$1,
                      couleur: c.$2,
                      nom: c.$3,
                      quand: c.$4,
                      apercu: c.$5,
                      pastille: c.$6,
                      active: c.$7,
                      onTap: c.$3 == 'Marc ❤️'
                          ? () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const ConversationMarc()))
                          : null),
              ])),
              // ——— Barre d'onglets iOS
              Container(
                  decoration: const BoxDecoration(
                      color: Color(0xFF161B20),
                      border:
                          Border(top: BorderSide(color: Color(0xFF2A3238), width: .5))),
                  padding: const EdgeInsets.only(top: 7, bottom: 4),
                  child: const Row(children: [
                    _Onglet(icone: Icons.sync, nom: 'Mises à jour'),
                    _Onglet(icone: Icons.call_outlined, nom: 'Appels'),
                    _Onglet(icone: Icons.groups_outlined, nom: 'Communautés'),
                    _Onglet(icone: Icons.chat, nom: 'Discussions', actif: true, badge: '3'),
                    _Onglet(icone: Icons.settings_outlined, nom: 'Réglages'),
                  ])),
              const SizedBox(height: 4),
              const BarreHome(),
              const SizedBox(height: 8),
            ])));
  }

  static Widget _rond(IconData ic, {VoidCallback? onTap, Color? fond, Color? couleur}) =>
      GestureDetector(
          onTap: onTap,
          child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: fond ?? const Color(0xFF1C242B), shape: BoxShape.circle),
              child: Icon(ic, color: couleur ?? waTexte, size: 19)));

  Widget _puce(String t, bool on) => Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
          color: on ? const Color(0xFF103629) : const Color(0xFF1C242B),
          borderRadius: BorderRadius.circular(16)),
      child: Text(t,
          style: TextStyle(
              color: on ? const Color(0xFF66D07E) : waTexte2,
              fontSize: 14,
              fontWeight: on ? FontWeight.w600 : FontWeight.w400)));
}

class _Onglet extends StatelessWidget {
  final IconData icone;
  final String nom;
  final bool actif;
  final String? badge;
  const _Onglet({required this.icone, required this.nom, this.actif = false, this.badge});
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(clipBehavior: Clip.none, children: [
          Icon(icone, color: actif ? waVert : waTexte2, size: 24),
          if (badge != null)
            Positioned(
                top: -4,
                right: -10,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    height: 16,
                    constraints: const BoxConstraints(minWidth: 16),
                    decoration: const BoxDecoration(
                        color: waVert,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Center(
                        child: Text(badge!,
                            style: const TextStyle(
                                color: Color(0xFF0B141A),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700))))),
        ]),
        const SizedBox(height: 3),
        Text(nom,
            style: TextStyle(
                color: actif ? waVert : waTexte2,
                fontSize: 10,
                fontWeight: actif ? FontWeight.w600 : FontWeight.w400)),
      ]));
}

class LigneConv extends StatelessWidget {
  final String initiale, nom, quand, apercu;
  final Color couleur;
  final String? pastille;
  final bool active;
  final VoidCallback? onTap;
  const LigneConv(
      {super.key,
      required this.initiale,
      required this.couleur,
      required this.nom,
      required this.quand,
      required this.apercu,
      this.pastille,
      required this.active,
      this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(children: [
            CircleAvatar(
                radius: 26,
                backgroundColor: couleur,
                child: Text(initiale,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(nom,
                        style: const TextStyle(
                            color: waTexte, fontSize: 17, fontWeight: FontWeight.w600))),
                Text(quand,
                    style: TextStyle(
                        color: active ? waVert : waTexte2, fontSize: 14.5)),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                Expanded(
                    child: Text(apercu,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: waTexte2, fontSize: 15))),
                if (pastille != null)
                  Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      height: 20,
                      constraints: const BoxConstraints(minWidth: 20),
                      decoration: BoxDecoration(
                          color: waVert, borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(pastille!,
                              style: const TextStyle(
                                  color: Color(0xFF0B141A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)))),
              ]),
            ])),
          ])));
}

// ————— La conversation « Marc ❤️ » — contenu réel de Coches bleues —————
class ConversationMarc extends StatelessWidget {
  const ConversationMarc({super.key});

  static const _messages = <(bool, String, String, String?)>[
    (true, 'Bonjour Sarah ❤️ Je suis très heureux de ton message. Comment se passe ta journée à toi ?', '10:12', '14 mars'),
    (false, "Bien ! C'est bizarre, j'ai l'impression qu'on se connaît depuis longtemps. Bref 😊 Tu es où là, en mer ?", '12:40', null),
    (true, 'Ma chérie ❤️🌹🌹 Cette nuit j\'ai pensé à notre maison près de Cassis. Tu es la reine de mon cœur.', '09:03', '2 avril'),
    (false, "Tu me manques. C'est ridicule non ? On s'est jamais vus et tu me manques ❤️", '22:51', '19 avril'),
    (true, 'Mon amour, la connexion satellite du navire est suspendue. 300 euros pour la rétablir. Sans cela nous ne pouvons plus parler… Je rembourse à Marseille, promis de mon cœur.', '11:20', '6 mai'),
    (true, "Un colis pour toi est bloqué en douane ma reine. 800 euros de frais. C'est mon cadeau pour toi, j'ai honte de demander.", '14:47', '11 juin'),
    (true, 'Bonne nuit, chère Monique.', '21:58', '28 juin'),
    (true, 'Pardon ma chérie !! Je pensais à ma tante Monique, je suis fatigué ce soir. Bonne nuit mon trésor ❤️', '21:59', null),
    (true, "Ma solde est bloquée par la compagnie. Il faut payer la caution de débarquement : 3000 euros. Sinon pas de Marseille le 28… Voici le compte de l'agent maritime : FR76 XXXX (M. OKAFOR AGENT MARITIME).", '10:31', '16 juillet'),
    (true, "N'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges comme je t'ai dit ❤️", '17:41', "aujourd'hui"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: waFond,
        body: SafeArea(
            bottom: false,
            child: Column(children: [
              const SizedBox(height: 8),
              const BarreStatut(),
              // ——— Header iOS : chevron vert, avatar, nom, appels
              Container(
                  color: const Color(0xFF161B20),
                  padding: const EdgeInsets.fromLTRB(2, 6, 14, 8),
                  child: Row(children: [
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child:
                                Icon(Icons.arrow_back_ios_new, color: waVert, size: 22))),
                    const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF5B7C99),
                        child: Text('M',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600))),
                    const SizedBox(width: 9),
                    const Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Marc ❤️',
                              style: TextStyle(
                                  color: waTexte,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600)),
                          Text('en ligne',
                              style: TextStyle(color: waTexte2, fontSize: 12.5)),
                        ])),
                    const Icon(Icons.videocam_outlined, color: waVert, size: 26),
                    const SizedBox(width: 22),
                    const Icon(Icons.call_outlined, color: waVert, size: 22),
                  ])),
              Expanded(
                  child: Container(
                      color: const Color(0xFF0B141A),
                      child: ListView(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                          children: [
                            for (final m in _messages) ...[
                              if (m.$4 != null)
                                Center(
                                    child: Container(
                                        margin:
                                            const EdgeInsets.only(top: 12, bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 13, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF182229),
                                            borderRadius: BorderRadius.circular(9)),
                                        child: Text(m.$4!,
                                            style: const TextStyle(
                                                color: waTexte2, fontSize: 12.5)))),
                              Align(
                                  alignment: m.$1
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding:
                                        const EdgeInsets.fromLTRB(11, 7, 11, 7),
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width * .75),
                                    decoration: BoxDecoration(
                                        color: m.$1 ? waBulleRecu : waBulleEnvoi,
                                        // iOS : bulles bien arrondies (16), pas les 8-10 d'Android
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(m.$1 ? 5 : 16),
                                            topRight: Radius.circular(m.$1 ? 16 : 5),
                                            bottomLeft: const Radius.circular(16),
                                            bottomRight: const Radius.circular(16))),
                                    child: Wrap(
                                        alignment: WrapAlignment.end,
                                        crossAxisAlignment: WrapCrossAlignment.end,
                                        children: [
                                          // iOS : corps de texte ~17, pas 14.5
                                          Text(m.$2,
                                              style: const TextStyle(
                                                  color: waTexte,
                                                  fontSize: 16.5,
                                                  height: 1.3)),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, top: 7),
                                              child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(m.$3,
                                                        style: TextStyle(
                                                            color: waTexte
                                                                .withValues(alpha: .5),
                                                            fontSize: 11)),
                                                    if (!m.$1) ...[
                                                      const SizedBox(width: 3),
                                                      const Icon(Icons.done_all,
                                                          color: cocheBleue, size: 16),
                                                    ],
                                                  ])),
                                        ]),
                                  )),
                            ],
                            const SizedBox(height: 6),
                          ]))),
              // ——— Saisie iOS : « + », champ avec autocollant, caméra, micro (pas de rond vert Android)
              Container(
                  color: const Color(0xFF161B20),
                  padding: const EdgeInsets.fromLTRB(10, 7, 12, 8),
                  child: Row(children: [
                    const Icon(Icons.add, color: waVert, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                                color: const Color(0xFF1C242B),
                                borderRadius: BorderRadius.circular(19),
                                border: Border.all(
                                    color: const Color(0xFF2A3238), width: .5)),
                            child: const Row(children: [
                              Spacer(),
                              Icon(Icons.sticky_note_2_outlined,
                                  color: waTexte2, size: 20),
                            ]))),
                    const SizedBox(width: 12),
                    const Icon(Icons.camera_alt_outlined, color: waVert, size: 24),
                    const SizedBox(width: 16),
                    const Icon(Icons.mic_none, color: waVert, size: 24),
                  ])),
              const SizedBox(height: 2),
              const BarreHome(),
              const SizedBox(height: 8),
            ])));
  }
}
