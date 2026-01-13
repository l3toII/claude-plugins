---
name: code-conventions
description: Code style and conventions for consistent, maintainable code. Use when writing code, reviewing, or setting up projects.
---

# Code Conventions

Standards for consistent, maintainable code.

## General Principles

1. **Clarity over cleverness** - Write code humans can read
2. **Consistency** - Follow existing patterns
3. **Minimal dependencies** - Only add what's needed
4. **Test coverage** - 80% minimum
5. **No warnings** - Lint must pass clean

## Naming Conventions

### Files

```
# Components (PascalCase)
UserProfile.tsx
AuthService.ts

# Utilities (camelCase)
formatDate.ts
validateEmail.ts

# Constants (SCREAMING_SNAKE)
API_ENDPOINTS.ts
ERROR_CODES.ts

# Tests (same name + .test)
UserProfile.test.tsx
AuthService.test.ts
```

### Variables

```typescript
// Boolean: is/has/can prefix
const isLoading = true;
const hasPermission = false;
const canEdit = true;

// Arrays: plural
const users = [];
const items = [];

// Functions: verb prefix
function getUser() {}
function validateInput() {}
function handleClick() {}

// Constants: UPPER_SNAKE
const MAX_RETRIES = 3;
```

## TypeScript

```typescript
// Prefer interfaces for objects
interface User {
  id: string;
  name: string;
  email: string;
}

// Use type for unions/intersections
type Status = 'pending' | 'active' | 'done';

// Explicit return types for public functions
function getUser(id: string): Promise<User> {}

// Use readonly for immutable data
interface Config {
  readonly apiUrl: string;
}
```

## React

```tsx
// Functional components only
function UserCard({ user }: { user: User }) {
  return <div>{user.name}</div>;
}

// Hooks at top level
function UserProfile() {
  const [user, setUser] = useState<User | null>(null);
  const { data } = useQuery(['user']);
  
  // Effects after state
  useEffect(() => {}, []);
  
  // Handlers before return
  const handleClick = () => {};
  
  return <div>...</div>;
}

// Props interface above component
interface ButtonProps {
  variant: 'primary' | 'secondary';
  onClick: () => void;
  children: React.ReactNode;
}

function Button({ variant, onClick, children }: ButtonProps) {}
```

## Error Handling

```typescript
// Custom errors with context
class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public context?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

// Always handle errors explicitly
try {
  await fetchUser(id);
} catch (error) {
  if (error instanceof ApiError) {
    logger.error('API failed', { statusCode: error.statusCode });
  }
  throw error;
}
```

## Imports Order

```typescript
// 1. External libraries
import { useState } from 'react';
import { z } from 'zod';

// 2. Internal modules (absolute)
import { UserService } from '@/services/user';
import { Button } from '@/components/ui';

// 3. Relative imports
import { formatName } from './utils';
import type { UserProps } from './types';
```

## Comments

```typescript
// Single line for simple explanations

/**
 * Multi-line for complex logic.
 * Explain WHY, not WHAT.
 */

// TODO(#ticket): Description of what needs to be done
// FIXME(#ticket): Description of the bug

// Never commit:
// console.log, debugger, commented-out code
```

## Testing

```typescript
describe('UserService', () => {
  describe('getUser', () => {
    it('should return user when found', async () => {
      // Arrange
      const mockUser = { id: '1', name: 'Test' };
      
      // Act
      const result = await service.getUser('1');
      
      // Assert
      expect(result).toEqual(mockUser);
    });

    it('should throw when user not found', async () => {
      await expect(service.getUser('invalid'))
        .rejects.toThrow('User not found');
    });
  });
});
```
