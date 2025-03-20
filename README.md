# AppTree Mobile Development Guide

This guide provides a comprehensive overview of building applications with AppTree Mobile, including detailed examples and explanations for each component.

## Table of Contents
1. [Record Definitions](#1-defining-records)
2. [Request Definitions](#2-defining-requests)
3. [Endpoint Types](#3-defining-endpoints)
4. [UI Components](#4-ui-components)
5. [Application Setup](#5-application-setup)

## 1. Defining Records

Records are the core data structures in your AppTree application. They represent your business entities and are defined using specialized Field types that provide built-in validation, serialization, and UI integration.

### Available Field Types

| Field Type | Description | Example Usage |
|------------|-------------|---------------|
| `StringField` | Text data with optional validation | Names, descriptions, emails |
| `IntField` | Integer values with range validation | Ages, counts, quantities |
| `DoubleField` | Decimal numbers with precision control | Prices, measurements |
| `BoolField` | Boolean true/false values | Status flags, toggles |
| `DateTimeField` | Date and time values with formatting | Timestamps, schedules |
| `ListField` | Arrays of other field types | Tags, multiple selections |
| `MapField` | Key-value pair objects | Dynamic attributes |
| `ReferenceField` | References to other Records | Relationships |
| `FileField` | File attachments with type validation | Documents, images |
| `GeoPointField` | Geographical coordinates | Location data |

### Comprehensive Record Example

```dart
class EmployeeRecord extends Record {
  // Personal Information
  final StringField firstName;
  final StringField lastName;
  final StringField email;
  final IntField age;
  final DateTimeField birthDate;
  final DateTimeField hireDate;
  
  // Work Details
  final StringField department;
  final StringField position;
  final DoubleField salary;
  final BoolField isFullTime;
  
  // Contact Information
  final MapField address;
  final ListField<StringField> phoneNumbers;
  
  // Relationships
  final ReferenceField<EmployeeRecord> supervisor;
  final ListField<ReferenceField<EmployeeRecord>> directReports;
  
  // Documents
  final FileField profilePicture;
  final ListField<FileField> documents;
  
  // Location
  final GeoPointField officeLocation;

  EmployeeRecord({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.birthDate,
    required this.hireDate,
    required this.department,
    required this.position,
    required this.salary,
    required this.isFullTime,
    required this.address,
    required this.phoneNumbers,
    required this.supervisor,
    required this.directReports,
    required this.profilePicture,
    required this.documents,
    required this.officeLocation,
  });

  // Custom validation
  @override
  List<ValidationError> validate() {
    final errors = <ValidationError>[];
    
    if (age.value < 18) {
      errors.add(ValidationError('age', 'Employee must be at least 18 years old'));
    }
    
    if (!email.value.contains('@')) {
      errors.add(ValidationError('email', 'Invalid email format'));
    }
    
    return errors;
  }

  // Custom computed property
  String get fullName => '${firstName.value} ${lastName.value}';
}
```

## 2. Defining Requests

Requests define the structure of data sent to and received from your API endpoints. They can combine both standard Dart types and Field types to match your API requirements.

### Example Request with Validation

```dart
class CreateEmployeeRequest {
  // Basic Information
  final StringField firstName;
  final StringField lastName;
  final String employeeId;  // Standard Dart type for internal reference
  
  // Employment Details
  final DateTimeField startDate;
  final StringField department;
  final DoubleField proposedSalary;
  
  // Contact Information
  final StringField email;
  final StringField phone;
  
  // Documents
  final List<FileField> onboardingDocuments;

  CreateEmployeeRequest({
    required this.firstName,
    required this.lastName,
    required this.employeeId,
    required this.startDate,
    required this.department,
    required this.proposedSalary,
    required this.email,
    required this.phone,
    required this.onboardingDocuments,
  });

  // Request validation
  List<String> validate() {
    final errors = <String>[];
    
    if (startDate.value.isBefore(DateTime.now())) {
      errors.add('Start date cannot be in the past');
    }
    
    if (proposedSalary.value < 0) {
      errors.add('Salary must be positive');
    }
    
    if (onboardingDocuments.isEmpty) {
      errors.add('At least one onboarding document is required');
    }
    
    return errors;
  }
}
```

## 3. Defining Endpoints

AppTree provides three specialized endpoint types, each designed for specific data access patterns. Here's a detailed look at each type with examples:

### 1. CollectionEndpoint

Used for managing collections of records with full CRUD (Create, Read, Update, Delete) operations.

```dart
class EmployeesEndpoint extends CollectionEndpoint<EmployeeRecord> {
  @override
  String get path => '/api/v1/employees';
  
  // Custom filtering
  @override
  Future<List<EmployeeRecord>> filter(String query) async {
    final response = await client.get('$path/search?q=$query');
    return response.map((json) => EmployeeRecord.fromJson(json)).toList();
  }
  
  // Custom sorting
  @override
  List<EmployeeRecord> sort(List<EmployeeRecord> records, String field) {
    switch (field) {
      case 'name':
        return records..sort((a, b) => a.fullName.compareTo(b.fullName));
      case 'salary':
        return records..sort((a, b) => a.salary.value.compareTo(b.salary.value));
      default:
        return records;
    }
  }
}
```

### 2. ListEndpoint

Optimized for read-only data access with efficient caching and filtering capabilities.

```dart
class ActiveEmployeesEndpoint extends ListEndpoint<EmployeeRecord> {
  @override
  String get path => '/api/v1/employees/active';
  
  // Cache configuration
  @override
  Duration get cacheDuration => Duration(minutes: 15);
  
  // Custom data transformation
  @override
  List<EmployeeRecord> transform(List<dynamic> data) {
    return data
      .map((json) => EmployeeRecord.fromJson(json))
      .where((employee) => employee.isFullTime.value)
      .toList();
  }
}
```

### 3. SubmissionEndpoint

Handles complex form submissions with validation and custom business logic.

```dart
class EmployeeOnboardingEndpoint extends SubmissionEndpoint<CreateEmployeeRequest> {
  @override
  String get path => '/api/v1/employees/onboard';
  
  // Pre-submission validation
  @override
  Future<bool> validate(CreateEmployeeRequest request) async {
    final errors = request.validate();
    if (errors.isNotEmpty) {
      throw ValidationException(errors.join(', '));
    }
    return true;
  }
  
  // Custom submission handling
  @override
  Future<void> submit(CreateEmployeeRequest request) async {
    // Upload documents first
    final documentUrls = await Future.wait(
      request.onboardingDocuments.map((doc) => uploadDocument(doc))
    );
    
    // Create employee record
    final response = await client.post(
      path,
      body: {
        ...request.toJson(),
        'documentUrls': documentUrls,
      },
    );
    
    if (response.statusCode != 200) {
      throw SubmissionException('Failed to create employee');
    }
  }
}
```

## 4. UI Components

AppTree provides powerful UI components for displaying and editing records. Here are detailed examples of RecordList and Form implementations:

### RecordList Example

```dart
class EmployeeList extends RecordList<EmployeeRecord> {
  @override
  Widget buildItem(BuildContext context, EmployeeRecord employee) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: employee.profilePicture.value != null
            ? NetworkImage(employee.profilePicture.value!)
            : null,
          child: employee.profilePicture.value == null
            ? Text(employee.firstName.value[0])
            : null,
        ),
        title: Text(employee.fullName),
        subtitle: Text(employee.position.value),
        trailing: Text('\$${employee.salary.value.toStringAsFixed(2)}'),
        onTap: () => navigateToDetail(context, employee),
      ),
    );
  }

  @override
  Widget buildHeader(BuildContext context) {
    return SearchBar(
      onChanged: (query) => filter(query),
      hintText: 'Search employees...',
    );
  }

  @override
  Widget buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 48.0),
          Text('No employees found'),
        ],
      ),
    );
  }
}
```

### Form Example

```dart
class EmployeeForm extends Form<EmployeeRecord> {
  @override
  List<Widget> buildFields(BuildContext context) {
    return [
      // Personal Information Section
      FormSection(
        title: 'Personal Information',
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'First Name'),
            initialValue: record.firstName.value,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            onSaved: (value) => record.firstName.value = value!,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Last Name'),
            initialValue: record.lastName.value,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            onSaved: (value) => record.lastName.value = value!,
          ),
          DateTimePicker(
            labelText: 'Birth Date',
            selectedDate: record.birthDate.value,
            onChanged: (date) => record.birthDate.value = date,
          ),
        ],
      ),

      // Employment Details Section
      FormSection(
        title: 'Employment Details',
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Department'),
            value: record.department.value,
            items: ['HR', 'IT', 'Finance', 'Sales']
              .map((dept) => DropdownMenuItem(
                value: dept,
                child: Text(dept),
              ))
              .toList(),
            onChanged: (value) => record.department.value = value!,
          ),
          NumberFormField(
            decoration: InputDecoration(labelText: 'Salary'),
            initialValue: record.salary.value,
            validator: (value) => value < 0 ? 'Invalid salary' : null,
            onSaved: (value) => record.salary.value = value,
          ),
          SwitchListTile(
            title: Text('Full Time Employee'),
            value: record.isFullTime.value,
            onChanged: (value) => record.isFullTime.value = value,
          ),
        ],
      ),

      // File Attachments Section
      FormSection(
        title: 'Documents',
        children: [
          FilePickerField(
            labelText: 'Profile Picture',
            file: record.profilePicture,
            allowedExtensions: ['jpg', 'png'],
          ),
          MultiFilePickerField(
            labelText: 'Additional Documents',
            files: record.documents,
            maxFiles: 5,
          ),
        ],
      ),
    ];
  }

  @override
  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      
      try {
        await record.save();
        Navigator.of(context).pop(true);
      } catch (e) {
        showErrorDialog(context, 'Failed to save employee: $e');
      }
    }
  }
}
```

## 5. Application Setup

Here's a complete example of setting up an AppTree application with authentication, theming, and navigation:

```dart
void main() async {
  // Initialize AppTree services
  await AppTree.initialize();

  // Configure authentication
  final auth = AppTreeAuth(
    baseUrl: 'https://api.example.com',
    clientId: 'your_client_id',
    clientSecret: 'your_client_secret',
  );

  // Define custom theme
  final theme = AppTreeTheme(
    primaryColor: Colors.indigo,
    accentColor: Colors.indigoAccent,
    cardTheme: CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.indigo,
      ),
      // ... other text styles
    ),
  );

  // Create and run the app
  final app = AppTreeApp(
    title: 'Employee Management System',
    theme: theme,
    auth: auth,
    home: DashboardScreen(),
    menuItems: [
      MenuItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        screen: DashboardScreen(),
      ),
      MenuItem(
        title: 'Employees',
        icon: Icons.people,
        endpoint: EmployeesEndpoint(),
        screen: EmployeeList(),
      ),
      MenuItem(
        title: 'Onboarding',
        icon: Icons.person_add,
        endpoint: EmployeeOnboardingEndpoint(),
        screen: EmployeeForm(),
      ),
      MenuItem(
        title: 'Reports',
        icon: Icons.bar_chart,
        screen: ReportsScreen(),
      ),
      MenuItem(
        title: 'Settings',
        icon: Icons.settings,
        screen: SettingsScreen(),
      ),
    ],
    // Error handling
    errorBuilder: (context, error) {
      return ErrorScreen(
        error: error,
        onRetry: () => Navigator.of(context).pop(),
      );
    },
    // Loading indicator
    loadingBuilder: (context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  runApp(app);
}
```

This setup provides:
1. Complete authentication configuration
2. Custom theme definition
3. Comprehensive navigation structure
4. Error handling and loading states
5. Integration of all previously defined components

Remember to:
- Initialize all required services before starting the app
- Configure proper authentication mechanisms
- Set up appropriate error handling and logging
- Test all CRUD operations thoroughly
- Implement proper form validation
- Follow security best practices
- Maintain consistent error handling across the application
- Document any custom implementations or configurations
5. Validate form submissions and data entry