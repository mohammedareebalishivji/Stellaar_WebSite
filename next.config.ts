import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  allowedDevOrigins: [
    'localhost:3000',
    process.env.NEXT_PUBLIC_LOCAL_IP || '127.0.0.1'
  ],
} as any; // Using 'as any' because the type definition might not have caught up yet

export default nextConfig;
