// Cartes (Wallet) — construit contre la vidéo de référence du 24/08 (48 écrans, iOS 26)
// D51-2 : pile de cartes, carte ouverte + transactions, DÉTAIL avec mini-carte Plans du lieu,
// menu réglages, flux d'ajout, pass. R3 : la carte LCL •••• 4417 = celle de Ma Banque ;
// les transactions recoupent les opérations bancaires ; le billet du 28 août = le pass.
import SwiftUI
import MapKit

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

// ============================================================ APP
struct CartesVueWallet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var carteOuverte = false
    @State private var billetOuvert = false
    @State private var ajoutVisible = false
    @State private var reglagesVisibles = false

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
                            Image(systemName: "magnifyingglass")
                            Image(systemName: "ellipsis").onTapGesture { reglagesVisibles = true }
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
        .sheet(isPresented: $ajoutVisible) { AjoutCarteVue() }
        .sheet(isPresented: $reglagesVisibles) { ReglagesCartesVue() }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ LES CARTES
struct CarteLCLVue: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(LinearGradient(colors: [Color(hex: 0x123E6B), Color(hex: 0x0A2340)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 190)
            .overlay(alignment: .topLeading) {
                Text("LCL").font(.system(size: 19, weight: .heavy)).italic().foregroundStyle(.white).padding(14)
            }
            .overlay(alignment: .topTrailing) {
                Text("VISA").font(.system(size: 15, weight: .bold)).italic().foregroundStyle(.white.opacity(0.9)).padding(14)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("•••• 4417").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white.opacity(0.9))
                    Text("SARAH LEVASSEUR").font(.system(size: 11, weight: .medium)).kerning(1).foregroundStyle(.white.opacity(0.75))
                }
                .padding(14)
            }
            .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
    }
}

struct CarteFideliteVue: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(LinearGradient(colors: [Color(hex: 0x8B5CF6), Color(hex: 0x5B21B6)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 190)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Phox Photo").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                    Text("Carte de fidélité").font(.system(size: 11)).foregroundStyle(.white.opacity(0.75))
                }
                .padding(14)
            }
            .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
    }
}

struct BilletSNCFVue: View {
    var compact: Bool = false
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(LinearGradient(colors: [Color(hex: 0x6E1E78), Color(hex: 0x43104A)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: compact ? 190 : 400)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("TGV INOUI").font(.system(size: 16, weight: .heavy)).foregroundStyle(.white)
                    Text("Lyon Part-Dieu → Marseille St-Charles").font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
                    Text("Ven. 28 août · 08:04").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white.opacity(0.9))
                }
                .padding(14)
            }
            .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
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
                        Image(systemName: "ellipsis").font(.system(size: 16)).foregroundStyle(.white)
                            .frame(width: 30, height: 30).background(Color(hex: 0x2C2C2E), in: Circle())
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

                    // Mini-carte du lieu du paiement (le beau détail de la référence)
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
                    .fill(LinearGradient(colors: [Color(hex: 0x6E1E78), Color(hex: 0x43104A)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 470)
                    .overlay {
                        VStack(spacing: 12) {
                            HStack {
                                Text("TGV INOUI 6173").font(.system(size: 17, weight: .heavy)).foregroundStyle(.white)
                                Spacer()
                                Text("SNCF").font(.system(size: 14, weight: .bold)).italic().foregroundStyle(.white.opacity(0.85))
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
                            // QR factice (motif déterministe)
                            RoundedRectangle(cornerRadius: 8).fill(.white)
                                .frame(width: 150, height: 150)
                                .overlay {
                                    VStack(spacing: 2) {
                                        ForEach(0..<15, id: \.self) { l in
                                            HStack(spacing: 2) {
                                                ForEach(0..<15, id: \.self) { c in
                                                    Rectangle().fill((l * 7 + c * 13 + l * c) % 3 == 0 ? .black : .white)
                                                        .frame(width: 7, height: 7)
                                                }
                                            }
                                        }
                                    }
                                }
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
                            TextField("", text: $numero).foregroundStyle(.white).keyboardType(.numberPad)
                        }
                        .padding(14)
                    }
                    .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16).padding(.top, 16)
                    Button { refus = true } label: {
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
            .navigationTitle("Ajouter une carte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            // Comportement iOS fidèle quand l'émetteur refuse (aucun réseau bancaire n'acceptera une carte fictive)
            .alert("Carte non ajoutée", isPresented: $refus) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Votre émetteur de carte n'a pas autorisé l'ajout de cette carte. Contactez votre banque pour en savoir plus.")
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ RÉGLAGES (menu ... — bascules réelles)
struct ReglagesCartesVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notifications = true
    @State private var remplissage = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Commandes").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Text("Aucune").font(.system(size: 14)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Text("Paiements préautorisés").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Text("Aucun").font(.system(size: 14)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Text("Remplissage automatique").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: $remplissage).labelsHidden().tint(Color(hex: 0x32D74B))
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Text("Notifications").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: $notifications).labelsHidden().tint(Color(hex: 0x32D74B))
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Text("Expirées").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Text("0 carte").font(.system(size: 14)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Cartes et Apple Pay")
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
