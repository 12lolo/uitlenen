# 📄 Technisch Ontwerp – Uitleen Website & App Firda

## Doel van het systeem

Het doel van dit technische ontwerp is om de frontend-implementaties (website en mobiele app) voor het Firda uitleensysteem te specificeren. Deze frontends zullen communiceren met de bestaande Uitleen-API en bieden gebruiksvriendelijke interfaces voor zowel studenten als docenten.

---

## 1. **Architectuur en technologieën**

### Architectuur

Het frontend-systeem bestaat uit twee hoofdcomponenten:

1. **Responsive Website**: Een web-applicatie gebouwd met Vue.js die communiceert met de bestaande API.
2. **Mobiele App**: Een hybride app gebouwd met React Native die dezelfde API gebruikt.

Beide frontends delen dezelfde architecturale principes:

* **State Management**: Centraal beheer van applicatiestatus
* **Component-based Design**: Herbruikbare UI-componenten
* **Service Layer**: Abstractielaag voor API-communicatie
* **Responsive/Adaptive Design**: Aanpassing aan verschillende schermformaten

### Technologieën

#### Website
* **Frontend Framework**: Vue.js 3 met Composition API
* **State Management**: Pinia
* **Routing**: Vue Router
* **UI Framework**: Tailwind CSS
* **HTTP Client**: Axios
* **Build Tool**: Vite
* **Testing**: Vitest en Cypress

#### Mobiele App
* **Framework**: React Native
* **State Management**: Redux Toolkit
* **Navigation**: React Navigation
* **API Communication**: Axios
* **Offline Storage**: Redux Persist met AsyncStorage
* **QR/Barcode Scanning**: Expo Barcode Scanner
* **Push Notifications**: Firebase Cloud Messaging
* **Testing**: Jest en Detox

---

## 2. **Frontend Architectuur**

### Website Architectuur

```
src/
├── assets/              # Statische bestanden (afbeeldingen, fonts)
├── components/          # Herbruikbare Vue-componenten
│   ├── common/          # Algemene componenten (buttons, inputs, etc.)
│   ├── layout/          # Layout componenten (header, footer, etc.)
│   ├── categories/      # Categorieën componenten
│   ├── items/           # Items componenten
│   └── admin/           # Admin dashboard componenten
├── views/               # Pagina componenten
│   ├── public/          # Publieke pagina's (home, catalogus)
│   └── admin/           # Admin pagina's (dashboard, beheer)
├── router/              # Vue Router configuratie
├── stores/              # Pinia stores
│   ├── auth.js          # Authenticatie state
│   ├── categories.js    # Categorieën state
│   ├── items.js         # Items state
│   └── loans.js         # Uitleningen state
├── services/            # API services
│   ├── api.service.js   # Basis API configuratie
│   ├── auth.service.js  # Authenticatie requests
│   ├── items.service.js # Items requests
│   └── ...
├── utils/               # Helper functies
└── App.vue              # Root component
```

### Mobiele App Architectuur

```
src/
├── assets/              # Statische bestanden (afbeeldingen, fonts)
├── components/          # Herbruikbare React Native componenten
│   ├── common/          # Algemene componenten (buttons, inputs, etc.)
│   ├── categories/      # Categorieën componenten
│   ├── items/           # Items componenten
│   └── admin/           # Admin dashboard componenten
├── screens/             # Schermen
│   ├── public/          # Publieke schermen
│   └── admin/           # Admin schermen
├── navigation/          # React Navigation configuratie
├── store/               # Redux store
│   ├── slices/          # Redux Toolkit slices
│   └── index.js         # Store configuratie
├── services/            # API services
│   ├── api.service.js   # Basis API configuratie
│   ├── auth.service.js  # Authenticatie requests
│   └── ...
├── utils/               # Helper functies
└── offline/             # Offline functionaliteit
    ├── sync.js          # Synchronisatie logica
    └── storage.js       # Lokale opslag
```

---

## 3. **Authentication & Authorization**

### Authenticatie Flow

1. **Login**:
   * Gebruiker voert inloggegevens in
   * Credentials worden verzonden naar `/api/login` endpoint
   * JWT token wordt ontvangen en opgeslagen

2. **Token Opslag**:
   * **Website**: HttpOnly cookie of localStorage
   * **Mobiele App**: Secure storage (Keychain/EncryptedSharedPreferences)

3. **Token Refresh**:
   * Automatische refresh van verlopen tokens
   * Interceptors voor 401 responses

4. **Logout**:
   * Token verwijderen uit opslag
   * Redirect naar login pagina
   * API call naar `/api/logout` indien nodig

### Autorisatie

* Rol-gebaseerde toegangscontrole (student vs docent)
* Route guards voor beschermde routes/schermen
* Conditionale rendering van UI-elementen gebaseerd op rol

---

## 4. **API Integratie**

### Service Layer

Beide frontends gebruiken een service layer om API-calls te abstraheren:

```javascript
// Voorbeeld API service (TypeScript syntax)
class ApiService {
  private axios: AxiosInstance;
  
  constructor() {
    this.axios = axios.create({
      baseURL: 'https://api.firda-uitleensysteem.nl/api',
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    });
    
    this.setupInterceptors();
  }
  
  private setupInterceptors() {
    this.axios.interceptors.request.use(config => {
      const token = getToken(); // Implementatie afhankelijk van platform
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });
    
    this.axios.interceptors.response.use(
      response => response,
      error => {
        if (error.response && error.response.status === 401) {
          // Handle token expiration
          logout();
        }
        return Promise.reject(error);
      }
    );
  }
  
  public get(url: string, params?: any) {
    return this.axios.get(url, { params });
  }
  
  public post(url: string, data: any) {
    return this.axios.post(url, data);
  }
  
  // Andere methodes (put, delete, etc.)
}
```

### Error Handling

* Consistente error handling over beide platforms
* Retry mechanisme voor tijdelijke netwerk-issues
* Gebruiksvriendelijke foutmeldingen
* Logging van errors voor debugging

---

## 5. **Offline Functionaliteit (Mobiele App)**

### Offline Opslag

* **Redux Persist** voor state persistence
* **AsyncStorage** als onderliggende opslagmechanisme
* Prioritaire data voor offline gebruik:
  * Categorieën
  * Items
  * Gebruikersinformatie
  * Actieve uitleningen

### Synchronisatie

```javascript
// Synchronisatie pseudo-code
class SyncService {
  // Queue voor acties die uitgevoerd moeten worden bij netwerk herstel
  private actionQueue = [];
  
  // Voeg actie toe aan queue wanneer offline
  public queueAction(action) {
    this.actionQueue.push({
      ...action,
      timestamp: Date.now()
    });
    this.persistQueue();
  }
  
  // Synchroniseer bij netwerk herstel
  public async syncOnReconnect() {
    if (this.actionQueue.length === 0) return;
    
    const actions = [...this.actionQueue];
    this.actionQueue = [];
    
    for (const action of actions) {
      try {
        await this.executeAction(action);
      } catch (error) {
        // Bij fout, terug in queue plaatsen
        this.actionQueue.push(action);
      }
    }
    
    this.persistQueue();
  }
  
  private async executeAction(action) {
    // Implementatie van verschillende actietypen
    switch(action.type) {
      case 'LOAN_ITEM':
        return apiService.post('/lendings', action.payload);
      case 'RETURN_ITEM':
        return apiService.post(`/lendings/${action.payload.id}/return`, action.payload);
      // Andere actietypen
    }
  }
  
  private persistQueue() {
    // Sla queue op in AsyncStorage
    AsyncStorage.setItem('syncQueue', JSON.stringify(this.actionQueue));
  }
}
```

### Netwerk Detectie

* Gebruik van `NetInfo` voor netwerk status monitoring
* Automatische synchronisatie bij herstel van verbinding
* Visuele indicator voor offline status

---

## 6. **QR-code Functionaliteit**

### QR-code Generatie (Website)

* QR-codes genereren voor items met unieke identificatie
* Gebruik van `qrcode.vue` voor generatie
* Printbare QR-codes met item-informatie

### QR-code Scanning (Mobiele App)

* Camera-integratie met `expo-barcode-scanner`
* Real-time scanning en decodering
* Directe navigatie naar item-details of actie na scan

```javascript
// QR-code scanner component pseudo-code
function QRScanner() {
  const [hasPermission, setHasPermission] = useState(null);
  const [scanned, setScanned] = useState(false);

  useEffect(() => {
    (async () => {
      const { status } = await BarCodeScanner.requestPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);

  const handleBarCodeScanned = async ({ data }) => {
    setScanned(true);
    try {
      // Aanname: QR bevat item ID of speciale URL
      const itemData = await apiService.get(`/items/by-qr/${data}`);
      navigation.navigate('ItemDetails', { item: itemData });
    } catch (error) {
      Alert.alert('Scan Error', 'Could not find item with this QR code');
    }
  };

  // Return component JSX
}
```

---

## 7. **Push Notificaties (Mobiele App)**

### Notificatie Setup

* Firebase Cloud Messaging (FCM) voor cross-platform notificaties
* Registratie van device tokens bij login
* Backend API uitbreiden voor device token opslag

### Notificatie Typen

* **Herinnering**: 24 uur voor inleverdatum
* **Deadline**: Op de dag van inleveren
* **Te laat**: 24 uur na deadline
* **Statuswijziging**: Bij wijziging van item status

### Notificatie Handling

```javascript
// Notificatie service pseudo-code
class NotificationService {
  // Initialiseer FCM
  async initialize() {
    await messaging().registerDeviceForRemoteMessages();
    const token = await messaging().getToken();
    await this.updateTokenOnServer(token);
    
    // Luister naar token refresh
    messaging().onTokenRefresh(token => {
      this.updateTokenOnServer(token);
    });
    
    // Voorgrond notificaties
    messaging().onMessage(async remoteMessage => {
      this.displayLocalNotification(remoteMessage);
    });
    
    // Achtergrond notificaties
    messaging().setBackgroundMessageHandler(async remoteMessage => {
      // Handle background message
    });
  }
  
  // Stuur token naar server
  async updateTokenOnServer(token) {
    try {
      await apiService.post('/user/device-token', { token });
    } catch (error) {
      console.error('Failed to update device token', error);
    }
  }
  
  // Toon lokale notificatie
  displayLocalNotification(notification) {
    // Implementatie afhankelijk van platform
  }
}
```

---

## 8. **State Management**

### Website (Vue.js + Pinia)

```javascript
// Voorbeeld Pinia store
import { defineStore } from 'pinia';
import { itemsService } from '@/services/items.service';

export const useItemsStore = defineStore('items', {
  state: () => ({
    items: [],
    loading: false,
    error: null,
    selectedCategory: null
  }),
  
  getters: {
    getItemsByCategory: (state) => {
      return state.selectedCategory 
        ? state.items.filter(item => item.category_id === state.selectedCategory)
        : state.items;
    },
    
    availableItems: (state) => {
      return state.items.filter(item => item.status === 'beschikbaar');
    }
  },
  
  actions: {
    async fetchItems() {
      this.loading = true;
      try {
        const response = await itemsService.getItems();
        this.items = response.data;
        this.error = null;
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    
    setSelectedCategory(categoryId) {
      this.selectedCategory = categoryId;
    }
    
    // Andere acties
  }
});
```

### Mobiele App (React Native + Redux)

```javascript
// Voorbeeld Redux slice
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { itemsService } from '../services/items.service';

export const fetchItems = createAsyncThunk(
  'items/fetchItems',
  async (_, { rejectWithValue }) => {
    try {
      const response = await itemsService.getItems();
      return response.data;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

const itemsSlice = createSlice({
  name: 'items',
  initialState: {
    items: [],
    loading: false,
    error: null,
    selectedCategory: null
  },
  reducers: {
    setSelectedCategory: (state, action) => {
      state.selectedCategory = action.payload;
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchItems.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchItems.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload;
        state.error = null;
      })
      .addCase(fetchItems.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  }
});

export const { setSelectedCategory } = itemsSlice.actions;
export default itemsSlice.reducer;
```

---

## 9. **Responsive Design (Website)**

### Breakpoints

| Naam    | Grootte (px) | Apparaat                  |
|---------|--------------|---------------------------|
| xs      | < 640        | Kleine mobiele apparaten  |
| sm      | ≥ 640        | Mobiele apparaten         |
| md      | ≥ 768        | Tablets                   |
| lg      | ≥ 1024       | Laptops                   |
| xl      | ≥ 1280       | Desktops                  |
| 2xl     | ≥ 1536       | Grote schermen            |

### Responsive Strategieën

* **Flexbox & Grid**: Voor flexibele layouts
* **Container Queries**: Voor componenten die zich aanpassen aan hun container
* **Mobile-first development**: Begin met mobiele layouts en breid uit
* **Dynamische font sizing**: Rem-gebaseerde typografie

---

## 10. **Adaptive Design (Mobiele App)**

### Platform-specifieke Aanpassingen

* **iOS vs Android**: Automatische aanpassing aan platform-specifieke UI-patronen
* **Form Factor**: Ondersteuning voor verschillende schermformaten (telefoon vs tablet)
* **Orientation**: Ondersteuning voor portrait en landscape modes

### Implementatie

```javascript
// Voorbeeld van platform-specifieke componenten
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    padding: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
      },
      android: {
        elevation: 5,
      },
    }),
  },
  
  // Andere stijlen
});
```

---

## 11. **Testing Strategy**

### Website Testing

* **Unit Tests**: Met Vitest voor individuele componenten en stores
* **Component Tests**: Met Vue Test Utils
* **E2E Tests**: Met Cypress voor volledige user flows
* **Accessibility Tests**: Met axe-core voor WCAG compliance

### Mobiele App Testing

* **Unit Tests**: Met Jest voor services en state management
* **Component Tests**: Met React Native Testing Library
* **E2E Tests**: Met Detox voor device testing
* **Offline Tests**: Specifieke tests voor offline functionaliteit

---

## 12. **Deployment Strategy**

### Website Deployment

* **Build Process**: Vite build pipeline
* **Hosting**: Vercel of Netlify voor statische hosting
* **CI/CD**: GitHub Actions voor automatische deployment
* **Environment Management**: Verschillende omgevingen (dev, staging, production)

### Mobiele App Deployment

* **Build Process**: React Native bundling
* **App Stores**: Publicatie op Google Play Store en Apple App Store
* **CI/CD**: Fastlane voor geautomatiseerde builds en deployment
* **Beta Testing**: TestFlight (iOS) en Google Play Beta (Android)

---

## 13. **Extra Notities**

* **Performance Optimalisatie**: Code splitting, lazy loading, caching
* **Toegankelijkheid**: WCAG 2.1 AA compliance voor website, mobiele toegankelijkheidsrichtlijnen
* **Internationalisatie**: Voorbereid voor meertalige ondersteuning
* **Analytics**: Integration met Google Analytics of Firebase Analytics
* **Error Reporting**: Sentry voor real-time monitoring van fouten
* **Security**: Regular security audits, HTTPS enforcement
