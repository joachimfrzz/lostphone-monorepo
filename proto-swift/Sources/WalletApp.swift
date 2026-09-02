// Cartes (Wallet) — construit contre la vidéo de référence du 24/08 (48 écrans, iOS 26)
// D51-2 : pile de cartes, carte ouverte + transactions, DÉTAIL avec mini-carte Plans du lieu,
// menu réglages, flux d'ajout, pass. R3 : la carte LCL •••• 4417 = celle de Ma Banque ;
// les transactions recoupent les opérations bancaires ; le billet du 28 août = le pass.
// v3 02/09 (retours Joachim, session 4) : QR code et code-barres RÉELS (CoreImage : un vrai QR lisible
// et un vrai Code 128) ; cartes redessinées (puce, hologramme, trame, logos, bande magnétique) ;
// boutons « … » retirés (le joueur n'a pas à supprimer ses cartes) ; micro absent.
import SwiftUI
import MapKit
import CoreImage
import CoreImage.CIFilterBuiltins

// ============================================================ DONNÉES (remplaçables — D59)
struct TransactionCarte: Identifiable {
    let id = UUID()
    var marchand: String
    var ville: String
    var date: String
    var montant: String
    var lat: Double
    var lon: Double
}

enum DonneesCartes {
    static let transactions: [TransactionCarte] = [
        TransactionCarte(marchand: "Boulangerie du Griffon", ville: "Lyon, Auvergne-Rhône-Alpes", date: "Hier",
                         montant: "3,40 €", lat: 45.7690, lon: 4.8350),
        TransactionCarte(marchand: "Pharmacie du Parc", ville: "Lyon, Auvergne-Rhône-Alpes", date: "12/08/2026",
                         montant: "23,90 €", lat: 45.7660, lon: 4.8370),
        TransactionCarte(marchand: "Carrefour City Lyon 1er", ville: "Lyon, Auvergne-Rhône-Alpes", date: "11/08/2026",
                         montant: "41,37 €", lat: 45.7680, lon: 4.8310),
        TransactionCarte(marchand: "Café Mokxa", ville: "Lyon, Auvergne-Rhône-Alpes", date: "09/08/2026",
                         montant: "7,80 €", lat: 45.7700, lon: 4.8330),
        TransactionCarte(marchand: "SNCF Connect", ville: "Achat en ligne", date: "10/08/2026",
                         montant: "47,00 €", lat: 45.7605, lon: 4.8590),
    ]
}

// ============================================================ CODES RÉELS (CoreImage) — v3
// Un QR code et un code-barres VRAIS : générés par le système, donc visuellement indiscernables des vrais
// (et lisibles par un lecteur). Le contenu encodé reste fictif (référence de billet, n° client).
enum CodesReels {
    private static let ctx = CIContext()
    static func qr(_ texte: String, taille: CGFloat = 300) -> UIImage? {
        let f = CIFilter.qrCodeGenerator()
        f.message = Data(texte.utf8)
        f.correctionLevel = "M"
        guard let out = f.outputImage else { return nil }
        let echelle = taille / out.extent.width
        let agrandie = out.transformed(by: CGAffineTransform(scaleX: echelle, y: echelle))
        guard let cg = ctx.createCGImage(agrandie, from: agrandie.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
    static func code128(_ texte: String, largeur: CGFloat = 640, hauteur: CGFloat = 160) -> UIImage? {
        let f = CIFilter.code128BarcodeGenerator()
        f.message = Data(texte.utf8)
        f.quietSpace = 4
        guard let out = f.outputImage else { return nil }
        let sx = largeur / out.extent.width, sy = hauteur / out.extent.height
        let agrandie = out.transformed(by: CGAffineTransform(scaleX: sx, y: sy))
        guard let cg = ctx.createCGImage(agrandie, from: agrandie.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}

struct QRCodeVue: View {
    let contenu: String
    var taille: CGFloat = 150
    var body: some View {
        RoundedRectangle(cornerRadius: 8).fill(.white)
            .frame(width: taille, height: taille)
            .overlay {
                if let img = CodesReels.qr(contenu, taille: taille * 3) {
                    Image(uiImage: img).interpolation(.none).resizable().scaledToFit().padding(taille * 0.06)
                }
            }
    }
}

struct CodeBarresVue: View {
    let contenu: String
    var body: some View {
        VStack(spacing: 6) {
            if let img = CodesReels.code128(contenu) {
                Image(uiImage: img).interpolation(.none).resizable().scaledToFit()
                    .frame(height: 80)
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .background(.white, in: RoundedRectangle(cornerRadius: 6))
            }
            Text(contenu.enumerated().map { $0.offset > 0 && $0.offset % 4 == 0 ? " \($0.element)" : String($0.element) }.joined())
                .font(.system(size: 12, weight: .medium, design: .monospaced)).foregroundStyle(.secondary)
        }
    }
}

// ============================================================ APP
struct CartesVueWallet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var carteOuverte = false
    @State private var billetOuvert = false
    @State private var ajoutVisible = false
    @State private var fideliteOuverte = false
    @State private var rechercheVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Cartes").font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                        Spacer()
                        HStack(spacing: 14) {
                            Image(systemName: "plus").onTapGesture { ajoutVisible = true }
                            Image(systemName: "magnifyingglass").onTapGesture { rechercheVisible = true }
                            // v3 : « … » retiré (réglages sans intérêt de jeu — Joachim)
                        }
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16).padding(.top, 6).padding(.bottom, 14)

                    // Pile de cartes (référence w001 : cartes empilées qui se chevauchent)
                    // Diff cercle 2 : chevauchement DENSE comme la référence (bande ~64 pt par carte)
                    ZStack(alignment: .top) {
                        CarteLCLVue()
                            .onTapGesture { carteOuverte = true }
                        CarteFideliteVue()
                            .offset(y: 64)
                            .onTapGesture { fideliteOuverte = true }
                        BilletSNCFVue(compact: true)
                            .offset(y: 128)
                            .onTapGesture { billetOuvert = true }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 330)
                    Spacer(minLength: 120)
                }
            }

            BarreHome { dismiss() }
        }
        .fullScreenCover(isPresented: $carteOuverte) { CarteOuverteVue() }
        .fullScreenCover(isPresented: $billetOuvert) { BilletOuvertVue() }
        .fullScreenCover(isPresented: $fideliteOuverte) { CarteFideliteOuverteVue() }
        .sheet(isPresented: $ajoutVisible) { AjoutCarteVue() }
        .sheet(isPresented: $rechercheVisible) { RechercheCartesVue() }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ LES CARTES (v3 : redessinées comme de vraies cartes Wallet)
// Trame fine, puce EMV, hologramme, sans-contact, numéros embossés — éléments d'une vraie carte bancaire.
struct TrameCarte: View {
    var body: some View {
        GeometryReader { geo in
            Path { p in
                var y: CGFloat = -geo.size.height
                while y < geo.size.height * 2 {
                    p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: geo.size.width, y: y + geo.size.height * 0.9))
                    y += 11
                }
            }
            .stroke(Color.white.opacity(0.05), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

struct PuceEMV: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(LinearGradient(colors: [Color(hex: 0xE8D48B), Color(hex: 0xB89A3C), Color(hex: 0xF0E2A8)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 34, height: 26)
            .overlay(
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 9)); p.addLine(to: CGPoint(x: 34, y: 9))
                    p.move(to: CGPoint(x: 0, y: 17)); p.addLine(to: CGPoint(x: 34, y: 17))
                    p.move(to: CGPoint(x: 12, y: 0)); p.addLine(to: CGPoint(x: 12, y: 26))
                    p.move(to: CGPoint(x: 22, y: 0)); p.addLine(to: CGPoint(x: 22, y: 26))
                }
                .stroke(Color(hex: 0x8A6E1E).opacity(0.7), lineWidth: 0.8)
            )
    }
}

struct SansContact: View {
    var body: some View {
        Image(systemName: "wave.3.right").font(.system(size: 15, weight: .medium)).foregroundStyle(.white.opacity(0.85))
    }
}

struct CarteLCLVue: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(LinearGradient(colors: [Color(hex: 0x1B4F8F), Color(hex: 0x0E2C55), Color(hex: 0x081B36)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 190)
            .overlay(TrameCarte().clipShape(RoundedRectangle(cornerRadius: 14)))
            .overlay(alignment: .topLeading) {
                HStack(spacing: 8) {
                    Text("LCL").font(.system(size: 20, weight: .heavy)).italic().foregroundStyle(.white)
                    Text("Visa Classic").font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.7)).padding(.top, 4)
                }
                .padding(14)
            }
            .overlay(alignment: .topTrailing) {
                SansContact().padding(16)
            }
            .overlay(alignment: .leading) {
                PuceEMV().padding(.leading, 14).offset(y: 4)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("•••• •••• •••• 4417").font(.system(size: 15, weight: .semibold, design: .monospaced)).foregroundStyle(.white.opacity(0.95)).kerning(1)
                    HStack {
                        Text("SARAH LEVASSEUR").font(.system(size: 11, weight: .medium)).kerning(1.2).foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        Text("EXP 08/28").font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(14)
            }
            .overlay(alignment: .bottomTrailing) {
                Text("VISA").font(.system(size: 20, weight: .heavy)).italic().foregroundStyle(.white).padding(14).padding(.bottom, 26)
            }
            .shadow(color: .black.opacity(0.55), radius: 8, y: 4)
    }
}

struct CarteFideliteVue: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(LinearGradient(colors: [Color(hex: 0x9D6BFF), Color(hex: 0x6D3BD9), Color(hex: 0x4A1F9E)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 190)
            .overlay(TrameCarte().clipShape(RoundedRectangle(cornerRadius: 14)))
            .overlay(alignment: .topLeading) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 8).fill(.white).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "camera.aperture").font(.system(size: 18, weight: .semibold)).foregroundStyle(Color(hex: 0x6D3BD9)))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Phox Photo").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                        Text("Carte de fidélité").font(.system(size: 11)).foregroundStyle(.white.opacity(0.75))
                    }
                }
                .padding(14)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("MEMBRE").font(.system(size: 9, weight: .semibold)).kerning(1).foregroundStyle(.white.opacity(0.6))
                    Text("Sarah Levasseur").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                }
                .padding(14)
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .trailing, spacing: 3) {
                    Text("POINTS").font(.system(size: 9, weight: .semibold)).kerning(1).foregroundStyle(.white.opacity(0.6))
                    Text("1 240").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                }
                .padding(14)
            }
            .shadow(color: .black.opacity(0.55), radius: 8, y: 4)
    }
}

// ============================================================ CARTE FIDÉLITÉ OUVERTE (Phox Photo)
struct CarteFideliteOuverteVue: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                .frame(width: 30, height: 30).background(Color(hex: 0x2C2C2E), in: Circle())
                        }
                        Spacer()
                        // v3 : « … » retiré (menu au milieu de l'écran + « Supprimer la carte » sans intérêt de jeu)
                    }
                    .padding(.horizontal, 16).padding(.top, 8)

                    CarteFideliteVue().padding(.horizontal, 16)

                    // v3 : CODE-BARRES RÉEL (Code 128) — celui qu'on scanne en caisse
                    VStack(spacing: 10) {
                        Text("Présentez ce code en caisse").font(.system(size: 13)).foregroundStyle(.secondary)
                        CodeBarresVue(contenu: "482100376294")
                    }
                    .padding(16)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        HStack {
                            Text("Points acquis").font(.system(size: 14)).foregroundStyle(.white)
                            Spacer()
                            Text("1 240 pts").font(.system(size: 14)).foregroundStyle(.white)
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Text("Valeur en bon d'achat").font(.system(size: 14)).foregroundStyle(.white)
                            Spacer()
                            Text("12,40 €").font(.system(size: 14)).foregroundStyle(.white)
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Text("Prochain palier").font(.system(size: 14)).foregroundStyle(.white)
                            Spacer()
                            Text("260 pts pour 15 €").font(.system(size: 14)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Text("Dernier passage").font(.system(size: 14)).foregroundStyle(.white)
                            Spacer()
                            Text("Phox Lyon Cordeliers · 31/07").font(.system(size: 14)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)

                    Spacer(minLength: 110)
                }
            }

            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ RECHERCHE CARTES
struct RechercheCartesVue: View {
    @Environment(\.dismiss) private var dismiss
    private let items = ["Carte LCL Visa •••• 4417", "Phox Photo — Fidélité", "TGV INOUI — Billet 28 août"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    Text("Cartes et passes").font(.system(size: 13)).foregroundStyle(.secondary)
                        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 8)
                    VStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.offset) { i, nom in
                            HStack {
                                Image(systemName: "creditcard").font(.system(size: 15)).foregroundStyle(.secondary)
                                    .frame(width: 26)
                                Text(nom).font(.system(size: 15)).foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 14).padding(.vertical, 11)
                            .contentShape(Rectangle())
                            .onTapGesture { dismiss() }
                            if i < items.count - 1 {
                                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 54)
                            }
                        }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    Spacer()
                }
            }
            .navigationTitle("Recherche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
    }
}

struct BilletSNCFVue: View {
    var compact: Bool = false
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(LinearGradient(colors: [Color(hex: 0x8A2C9E), Color(hex: 0x5E1A6E), Color(hex: 0x3A0F45)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: compact ? 190 : 400)
            .overlay(TrameCarte().clipShape(RoundedRectangle(cornerRadius: 14)))
            .overlay(alignment: .topLeading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("TGV INOUI").font(.system(size: 16, weight: .heavy)).foregroundStyle(.white)
                        Text("Lyon Part-Dieu → Marseille St-Charles").font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
                        Text("Ven. 28 août · 08:04").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white.opacity(0.9))
                    }
                    Spacer()
                    RoundedRectangle(cornerRadius: 6).fill(.white).frame(width: 40, height: 22)
                        .overlay(Text("SNCF").font(.system(size: 10, weight: .heavy)).italic().foregroundStyle(Color(hex: 0x8A2C9E)))
                }
                .padding(14)
            }
            .shadow(color: .black.opacity(0.55), radius: 8, y: 4)
    }
}

// ============================================================ CARTE OUVERTE + TRANSACTIONS
struct CarteOuverteVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var transaction: TransactionCarte? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                .frame(width: 30, height: 30).background(Color(hex: 0x2C2C2E), in: Circle())
                        }
                        Spacer()
                        // v3 : « … » retiré (Joachim)
                    }
                    .padding(.horizontal, 16).padding(.top, 8)

                    CarteLCLVue().padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Dernières transactions").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                        ForEach(DonneesCartes.transactions) { t in
                            Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(t.marchand).font(.system(size: 14.5)).foregroundStyle(.white)
                                    Text("\(t.ville) · \(t.date)").font(.system(size: 12)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(t.montant).font(.system(size: 14.5)).monospacedDigit().foregroundStyle(.white)
                                Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 9)
                            .contentShape(Rectangle())
                            .onTapGesture { transaction = t }
                        }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    Spacer(minLength: 110)
                }
            }

            BarreHome { dismiss() }
        }
        .sheet(item: $transaction) { t in TransactionVue(transaction: t) }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ DÉTAIL TRANSACTION (mini-carte Plans du lieu — référence w015)
struct TransactionVue: View {
    @Environment(\.dismiss) private var dismiss
    let transaction: TransactionCarte
    @State private var signalement = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(spacing: 4) {
                        Text(transaction.montant).font(.system(size: 38, weight: .bold)).foregroundStyle(.white)
                        Text("\(transaction.marchand), \(transaction.ville)").font(.system(size: 13)).foregroundStyle(.secondary)
                        Text(transaction.date).font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    VStack(spacing: 0) {
                        HStack {
                            Text("État : accepté").font(.system(size: 14)).foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Text("Total").font(.system(size: 14)).foregroundStyle(.white)
                            Spacer()
                            Text(transaction.montant).font(.system(size: 14)).foregroundStyle(.white)
                        }
                        .padding(14)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))

                    if transaction.ville != "Achat en ligne" {
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: transaction.lat, longitude: transaction.lon),
                            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)))) {
                            Annotation(transaction.marchand, coordinate: CLLocationCoordinate2D(latitude: transaction.lat, longitude: transaction.lon)) {
                                Circle().fill(Color(hex: 0xE8873D)).frame(width: 22, height: 22)
                                    .overlay(Image(systemName: "cart.fill").font(.system(size: 10)).foregroundStyle(.white))
                            }
                        }
                        .frame(height: 170)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .allowsHitTesting(false)
                    }

                    VStack(spacing: 0) {
                        Text("Contacter LCL")
                            .font(.system(size: 14)).foregroundStyle(Color(hex: 0x0A84FF))
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                            .contentShape(Rectangle())
                            .onTapGesture { Routeur.partage.allerTelephone("09 69 36 30 30") }
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        Text("Signaler des informations incorrectes")
                            .font(.system(size: 14)).foregroundStyle(Color(hex: 0x0A84FF))
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                            .contentShape(Rectangle())
                            .onTapGesture { Haptique.leger(); signalement = true }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))

                    Text("L'app Cartes utilise Plans pour fournir le nom, la catégorie et la position du commerçant liés à ce paiement.")
                        .font(.system(size: 11.5)).foregroundStyle(.secondary)
                }
                .padding(16)
            }
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .alert("Signalement envoyé", isPresented: $signalement) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Votre signalement a été transmis à LCL. Notre équipe examinera cette transaction dans les 48 h.")
        }
    }
}

// ============================================================ BILLET OUVERT (le pass du 28 août)
struct BilletOuvertVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            VStack(spacing: 14) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 30, height: 30).background(Color(hex: 0x2C2C2E), in: Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.top, 8)

                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [Color(hex: 0x8A2C9E), Color(hex: 0x5E1A6E), Color(hex: 0x3A0F45)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 490)
                    .overlay(TrameCarte().clipShape(RoundedRectangle(cornerRadius: 16)))
                    .overlay {
                        VStack(spacing: 12) {
                            HStack {
                                Text("TGV INOUI 6173").font(.system(size: 17, weight: .heavy)).foregroundStyle(.white)
                                Spacer()
                                RoundedRectangle(cornerRadius: 6).fill(.white).frame(width: 44, height: 24)
                                    .overlay(Text("SNCF").font(.system(size: 11, weight: .heavy)).italic().foregroundStyle(Color(hex: 0x8A2C9E)))
                            }
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("LYON PD").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                                    Text("08:04").font(.system(size: 13)).foregroundStyle(.white.opacity(0.8))
                                }
                                Spacer()
                                Image(systemName: "arrow.right").foregroundStyle(.white.opacity(0.7))
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("MARSEILLE").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                                    Text("09:47").font(.system(size: 13)).foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            HStack {
                                ChampBillet(cle: "DATE", valeur: "Ven. 28 août")
                                Spacer()
                                ChampBillet(cle: "VOITURE", valeur: "12")
                                Spacer()
                                ChampBillet(cle: "PLACE", valeur: "74")
                            }
                            HStack {
                                ChampBillet(cle: "PASSAGER", valeur: "SARAH LEVASSEUR")
                                Spacer()
                                ChampBillet(cle: "RÉF.", valeur: "QVRTGB")
                            }
                            Spacer()
                            // v3 : VRAI QR code (contenu : référence du billet fictif)
                            QRCodeVue(contenu: "SNCF|TGV6173|20260828|0804|LYD-MSC|V12P74|LEVASSEUR SARAH|QVRTGB", taille: 170)
                            Text("Présentez ce code au contrôle").font(.system(size: 11)).foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(18)
                    }
                    .padding(.horizontal, 22)
                Spacer()
            }

            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
    }
}

struct ChampBillet: View {
    let cle: String
    let valeur: String
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(cle).font(.system(size: 9, weight: .semibold)).kerning(0.5).foregroundStyle(.white.opacity(0.6))
            Text(valeur).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
        }
    }
}

// ============================================================ AJOUT (flux réel jusqu'au refus émetteur — comportement iOS fidèle)
struct AjoutCarteVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var etape = 0
    @State private var numero = ""
    @State private var refus = false
    @FocusState private var champActif: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                if etape == 0 {
                    Spacer()
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .frame(width: 280, height: 175)
                        .overlay(Text("Placez votre carte dans le cadre").font(.system(size: 13)).foregroundStyle(.secondary))
                    Text("Ajoutez les informations de la carte physique")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    Text("Apple peut utiliser les quatre derniers chiffres pour identifier les transactions.")
                        .font(.system(size: 12.5)).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center).padding(.horizontal, 40)
                    Button { etape = 1 } label: {
                        Text("Saisir manuellement").font(.system(size: 15, weight: .semibold)).foregroundStyle(Color(hex: 0x0A84FF))
                    }
                    Spacer()
                } else {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Numéro").font(.system(size: 14)).foregroundStyle(.secondary).frame(width: 76, alignment: .leading)
                            TextField("", text: $numero).foregroundStyle(.white).keyboardType(.numberPad).focused($champActif)
                        }
                        .padding(14)
                    }
                    .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16).padding(.top, 16)
                    Button { champActif = false; refus = true } label: {
                        Text("Continuer").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 13)
                            .background(numero.count >= 8 ? Color(hex: 0x0A84FF) : Color(hex: 0x3A3A3C), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(numero.count < 8)
                    .padding(.horizontal, 16)
                    Spacer()
                }
            }
            .background(Color.black)
            .contentShape(Rectangle())
            .onTapGesture { champActif = false }
            .navigationTitle("Ajouter une carte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { champActif = false }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            .alert("Carte non ajoutée", isPresented: $refus) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Votre émetteur de carte n'a pas autorisé l'ajout de cette carte. Contactez votre banque pour en savoir plus.")
            }
        }
        .preferredColorScheme(.dark)
    }
}
