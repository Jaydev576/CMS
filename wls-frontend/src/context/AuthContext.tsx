import { useEffect, type ReactNode } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ApiError, fetchUserProfile, loginUser } from "../api/auth";
import { AuthContext } from "./AuthContextValue";

export function AuthProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient();

  const {
    data: user = null,
    isLoading,
    isError,
    error,
  } = useQuery({
    queryKey: ["userProfile"],
    queryFn: fetchUserProfile,
    retry: false,
    refetchOnMount: "always",
    refetchOnWindowFocus: true,
    staleTime: 0,
  });

  const isUnauthorized = error instanceof ApiError && error.status === 401;

  useEffect(() => {
    if (!isUnauthorized) {
      return;
    }
    queryClient.setQueryData(["userProfile"], null);
  }, [isUnauthorized, queryClient]);

  useEffect(() => {
    if (!user) {
      return;
    }

    const timeoutMs = Math.max(user.sessionTimeoutSeconds, 1) * 1000 + 250;
    const timeoutId = window.setTimeout(() => {
      queryClient.refetchQueries({
        queryKey: ["userProfile"],
        exact: true,
        type: "active",
      });
    }, timeoutMs);

    return () => {
      window.clearTimeout(timeoutId);
    };
  }, [queryClient, user]);

  const loginMutation = useMutation({
    mutationFn: loginUser,
    onSuccess: async () => {
      await queryClient.refetchQueries({
        queryKey: ["userProfile"],
        exact: true,
      });
    },
  });

  const login = async (username: string, password: string) => {
    return loginMutation.mutateAsync({ username, password });
  };

  const logout = async () => {
    try {
      await fetch("/wls/api/Logout", {
        method: "POST",
        credentials: "include",
      });
    } catch (error) {
      console.error(error);
    } finally {
      queryClient.setQueryData(["userProfile"], null);
      await queryClient.invalidateQueries({ queryKey: ["userProfile"] });
    }
  };

  const value = {
    user: isUnauthorized ? null : user,
    login,
    logout,
    isAuthenticated: !isUnauthorized && user !== null,
    isLoading,
    isError,
    isAuthenticating: loginMutation.isPending,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
