<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
    {
        $roles = [
            [
                'name' => 'Super Admin',
                'slug' => 'super-admin',
                'permissions' => json_encode([
                    'create-projects' => true,
                    'edit-projects' => true,
                    'delete-projects' => true,
                    'manage-users' => true,
                    'manage-roles' => true,
                ])
            ],
            [
                'name' => 'Project Admin',
                'slug' => 'project-admin',
                'permissions' => json_encode([
                    'create-projects' => true,
                    'edit-projects' => true,
                    'delete-projects' => false,
                    'manage-users' => false,
                    'manage-roles' => false,
                ])
            ],
            [
                'name' => 'Team Member',
                'slug' => 'team-member',
                'permissions' => json_encode([
                    'create-projects' => false,
                    'edit-projects' => false,
                    'delete-projects' => false,
                    'manage-users' => false,
                    'manage-roles' => false,
                ])
            ],
            [
                'name' => 'Guest',
                'slug' => 'guest',
                'permissions' => json_encode([
                    'create-projects' => false,
                    'edit-projects' => false,
                    'delete-projects' => false,
                    'manage-users' => false,
                    'manage-roles' => false,
                ])
            ],
        ];
        
        foreach ($roles as $role) {
            Role::create($role);
        }
    }
}
